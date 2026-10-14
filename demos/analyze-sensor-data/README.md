# Demo 5: Analyze the Sensor Data

**Minimum tier:** Medium · **Result:** a detected bearing fault frequency that matches the value physics predicts.

Accelerometer data from a bearing test rig. The bearing has an outer-race defect; every time a rolling element passes it, the impact rings the structure. Your agent's job is to find the defect's signature in the data and write up the analysis as a runnable report. The answer is checkable: outer-race fault frequency is computable from the rig metadata below, so this is analysis with a right answer, not a plot for its own sake.

## Rig metadata

| Parameter | Value |
|-----------|-------|
| Sample rate | 12,800 Hz |
| Shaft speed | 1,800 rpm (30 Hz) |
| Rolling elements | 9 |
| Ball/pitch diameter ratio (d/D) | 0.28 |
| Contact angle | 0 degrees |

The outer-race ball pass frequency is computable from these parameters, and `verifyDemo.m` checks the agent's answer against it. Give the agent only the starter prompt below, which includes the rig parameters but not the answer; the point is that it finds the frequency itself.

## Setup

```matlab
generateBearingData   % writes bearing_vibration.csv (deterministic, seeded)
```

## The starter prompt

Start your agent in this folder and paste:

```
bearing_vibration.csv contains accelerometer data from a bearing test rig
(sample rate 12800 Hz, shaft speed 1800 rpm, 9 rolling elements, d/D 0.28,
contact angle 0). Analyze the vibration to determine whether there is a
bearing defect and identify the defect frequency. Impacts from a defect
excite a high-frequency structural resonance, so use envelope analysis:
first isolate the resonance band by zeroing the FFT outside a few-kHz band
around the strongest high-frequency content and inverse-transforming (base
MATLAB is enough; no toolbox needed), then rectify and look at the
low-frequency spectrum of the envelope. Do not skip the band isolation
step; rectifying the raw signal doubles the shaft frequency into a
misleading line. Save your
conclusion as results.mat containing a variable detectedFaultFrequency in
Hz, and write the analysis as a plain-text Live Script report named
bearingReport.m with your figures and reasoning.
```

## Verify

```matlab
verifyDemo
```

Checks `results.mat` against the geometry-predicted 97.2 Hz within 2 Hz, and that the report script runs. Base MATLAB&reg; is enough: rectified-signal FFT is a serviceable envelope analysis without any toolbox.
