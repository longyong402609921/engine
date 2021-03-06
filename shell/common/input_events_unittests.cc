// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "flutter/shell/common/shell_test.h"
#include "flutter/testing/testing.h"

namespace flutter {
namespace testing {

// Throughout these tests, the choice of time unit is irrelevant as long as all
// times have the same units.
using UnitlessTime = int;

// Signature of a generator function that takes the frame index as input and
// returns the time of that frame.
using Generator = std::function<UnitlessTime(int)>;

//----------------------------------------------------------------------------
/// Simulate n input events where the i-th one is delivered at delivery_time(i).
///
/// Simulation results will be written into events_consumed_at_frame whose
/// length will be equal to the number of frames drawn. Each element in the
/// vector is the number of input events consumed up to that frame. (We can't
/// return such vector because ASSERT_TRUE requires return type of void.)
///
/// We assume (and check) that the delivery latency is some base latency plus a
/// random latency where the random latency must be within one frame:
///
///   1.  latency = delivery_time(i) - j * frame_time = base_latency +
///       random_latency
///   2.  0 <= base_latency, 0 <= random_latency < frame_time
///
/// We also assume that there will be at least one input event per frame if
/// there were no latency. Let j = floor( (delivery_time(i) - base_latency) /
/// frame_time ) be the frame index if there were no latency. Then the set of j
/// should be all integers from 0 to continuous_frame_count - 1 for some
/// integer continuous_frame_count.
///
/// (Note that there coulds be multiple input events within one frame.)
///
/// The test here is insensitive to the choice of time unit as long as
/// delivery_time and frame_time are in the same unit.
static void TestSimulatedInputEvents(
    ShellTest* fixture,
    int num_events,
    UnitlessTime base_latency,
    Generator delivery_time,
    UnitlessTime frame_time,
    std::vector<UnitlessTime>& events_consumed_at_frame) {
  ///// Begin constructing shell ///////////////////////////////////////////////
  auto settings = fixture->CreateSettingsForFixture();
  std::unique_ptr<Shell> shell = fixture->CreateShell(settings);

  auto configuration = RunConfiguration::InferFromSettings(settings);
  configuration.SetEntrypoint("onPointerDataPacketMain");

  // The following 4 variables are only accessed in the UI thread by
  // nativeOnPointerDataPacket and nativeOnBeginFrame between their
  // initializations and `shell.reset()`.
  events_consumed_at_frame.clear();
  bool will_draw_new_frame = true;
  int events_consumed = 0;
  int frame_drawn = 0;
  auto nativeOnPointerDataPacket = [&events_consumed_at_frame,
                                    &will_draw_new_frame, &events_consumed,
                                    &frame_drawn](Dart_NativeArguments args) {
    events_consumed += 1;
    if (will_draw_new_frame) {
      frame_drawn += 1;
      will_draw_new_frame = false;
      events_consumed_at_frame.push_back(events_consumed);
    } else {
      events_consumed_at_frame.back() = events_consumed;
    }
  };
  fixture->AddNativeCallback("NativeOnPointerDataPacket",
                             CREATE_NATIVE_ENTRY(nativeOnPointerDataPacket));

  auto nativeOnBeginFrame = [&will_draw_new_frame](Dart_NativeArguments args) {
    will_draw_new_frame = true;
  };
  fixture->AddNativeCallback("NativeOnBeginFrame",
                             CREATE_NATIVE_ENTRY(nativeOnBeginFrame));

  ASSERT_TRUE(configuration.IsValid());
  fixture->RunEngine(shell.get(), std::move(configuration));
  ///// End constructing shell /////////////////////////////////////////////////

  ASSERT_GE(base_latency, 0);

  // Check that delivery_time satisfies our assumptions.
  int continuous_frame_count = 0;
  for (int i = 0; i < num_events; i += 1) {
    // j is the frame index of event i if there were no latency.
    int j = static_cast<int>((delivery_time(i) - base_latency) / frame_time);
    if (j == continuous_frame_count) {
      continuous_frame_count += 1;
    }
    double random_latency = delivery_time(i) - j * frame_time - base_latency;
    ASSERT_GE(random_latency, 0);
    ASSERT_LT(random_latency, frame_time);

    // If there were no latency, there should be at least one event per frame.
    // Hence j should never skip any integer less than continuous_frame_count.
    ASSERT_LT(j, continuous_frame_count);
  }

  // i is the input event's index.
  // j is the frame's index.
  for (int i = 0, j = 0; i < num_events; j += 1) {
    double t = j * frame_time;
    while (i < num_events && delivery_time(i) <= t) {
      ShellTest::DispatchFakePointerData(shell.get());
      i += 1;
    }
    ShellTest::PumpOneFrame(shell.get());
  }

  shell.reset();
}

TEST_F(ShellTest, MissAtMostOneFrameForIrregularInputEvents) {
  // We don't use `constexpr int frame_time` here because MSVC doesn't handle
  // it well with lambda capture.
  UnitlessTime frame_time = 10;
  UnitlessTime base_latency = 0.5 * frame_time;
  Generator extreme = [frame_time, base_latency](int i) {
    return static_cast<UnitlessTime>(
        i * frame_time + base_latency +
        (i % 2 == 0 ? 0.1 * frame_time : 0.9 * frame_time));
  };
  constexpr int n = 40;
  std::vector<int> events_consumed_at_frame;
  TestSimulatedInputEvents(this, n, base_latency, extreme, frame_time,
                           events_consumed_at_frame);
  int frame_drawn = events_consumed_at_frame.size();
  ASSERT_GE(frame_drawn, n - 1);
}

TEST_F(ShellTest, DelayAtMostOneEventForFasterThanVSyncInputEvents) {
  // We don't use `constexpr int frame_time` here because MSVC doesn't handle
  // it well with lambda capture.
  UnitlessTime frame_time = 10;
  UnitlessTime base_latency = 0.2 * frame_time;
  Generator double_sampling = [frame_time, base_latency](int i) {
    return static_cast<UnitlessTime>(i * 0.5 * frame_time + base_latency);
  };
  constexpr int n = 40;
  std::vector<int> events_consumed_at_frame;
  TestSimulatedInputEvents(this, n, base_latency, double_sampling, frame_time,
                           events_consumed_at_frame);

  // Draw one extra frame due to delaying a pending packet for the next frame.
  int frame_drawn = events_consumed_at_frame.size();
  ASSERT_EQ(frame_drawn, n / 2 + 1);

  for (int i = 0; i < n / 2; i += 1) {
    ASSERT_GE(events_consumed_at_frame[i], 2 * i - 1);
  }
}

TEST_F(ShellTest, HandlesActualIphoneXsInputEvents) {
  // Actual delivery times measured on iPhone Xs, in the unit of frame_time
  // (16.67ms for 60Hz).
  constexpr double iphone_xs_times[] = {0.15,
                                        1.0773046874999999,
                                        2.1738720703124996,
                                        3.0579052734374996,
                                        4.0890087890624995,
                                        5.0952685546875,
                                        6.1251708984375,
                                        7.1253076171875,
                                        8.125927734374999,
                                        9.37248046875,
                                        10.133950195312499,
                                        11.161201171875,
                                        12.226992187499999,
                                        13.1443798828125,
                                        14.440327148437499,
                                        15.091684570312498,
                                        16.138681640625,
                                        17.126469726562497,
                                        18.1592431640625,
                                        19.371372070312496,
                                        20.033774414062496,
                                        21.021782226562497,
                                        22.070053710937497,
                                        23.325541992187496,
                                        24.119648437499997,
                                        25.084262695312496,
                                        26.077866210937497,
                                        27.036547851562496,
                                        28.035073242187497,
                                        29.081411132812498,
                                        30.066064453124998,
                                        31.089360351562497,
                                        32.086142578125,
                                        33.4618798828125,
                                        34.14697265624999,
                                        35.0513525390625,
                                        36.136025390624994,
                                        37.1618408203125,
                                        38.144472656249995,
                                        39.201123046875,
                                        40.4339501953125,
                                        41.1552099609375,
                                        42.102128906249995,
                                        43.0426318359375,
                                        44.070131835937495,
                                        45.08862304687499,
                                        46.091469726562494};
  constexpr int n = sizeof(iphone_xs_times) / sizeof(iphone_xs_times[0]);
  // We don't use `constexpr int frame_time` here because MSVC doesn't handle
  // it well with lambda capture.
  UnitlessTime frame_time = 10000;
  for (double base_latency_f = 0; base_latency_f < 1; base_latency_f += 0.1) {
    // Everything is converted to int to avoid floating point error in
    // TestSimulatedInputEvents.
    UnitlessTime base_latency =
        static_cast<UnitlessTime>(base_latency_f * frame_time);
    Generator iphone_xs_generator = [frame_time, iphone_xs_times,
                                     base_latency](int i) {
      return base_latency +
             static_cast<UnitlessTime>(iphone_xs_times[i] * frame_time);
    };
    std::vector<int> events_consumed_at_frame;
    TestSimulatedInputEvents(this, n, base_latency, iphone_xs_generator,
                             frame_time, events_consumed_at_frame);
    int frame_drawn = events_consumed_at_frame.size();
    ASSERT_GE(frame_drawn, n - 1);
  }
}

}  // namespace testing
}  // namespace flutter
