# Profiling Notes

This document explains the profiling artifacts preserved in `results/`. It does not add new hardware measurements.

## What Was Profiled

The original project notes describe profiling of an optimized digit-classification CNN in an EFM32GG11 MCU deployment context. The documented metrics include:

- Flash usage.
- RAM usage.
- Energy per image.
- Validation accuracy.
- Model size.

The repository includes before/after screenshots from the original project materials:

- `results/ProfilingBeforePruning.png`
- `results/ProfilingAfterPruning.png`

## What the Screenshots Represent

The before screenshot represents the profiling state before the pruning-focused optimization workflow. The after screenshot represents the profiling state after pruning and quantization.


## Interpreting Flash, RAM, and Energy

Flash usage indicates how much non-volatile program or model storage is needed on the target system. Lower Flash usage can make a model easier to deploy on MCU-class hardware.

RAM usage reflects volatile memory pressure during execution. In embedded ML, RAM can be consumed by input buffers, intermediate activations, runtime state, and other firmware components.

Energy per image estimates the energy cost of running inference for one input image. Lower energy per inference is important for resource-constrained systems, especially battery-powered devices.

Accuracy should be interpreted alongside these resource metrics. A smaller model is not automatically better if accuracy falls below the application's acceptable threshold.


