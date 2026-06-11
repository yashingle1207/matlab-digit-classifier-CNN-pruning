# Methodology

This document explains the technical workflow represented by the MATLAB source and original project notes. It is written as supporting documentation for the cleaned-up portfolio repository, not as a new measurement report.

## CNN Training Setup

The project uses MATLAB to train a small convolutional neural network for digit classification. The script loads a digit dataset, separates training and validation data, trains a baseline CNN, and evaluates validation accuracy before optimization.

The workflow depends on helper functions from the original coursework environment, including dataset loading, mini-batch preprocessing, model training, and accuracy evaluation utilities. Those helper functions are referenced by the script but are not all present in this cleaned repository.

## L1-Norm Structured Pruning

The pruning stage ranks convolutional filters using an L1-norm based importance score. Filters with lower aggregate weight magnitude are treated as lower-priority candidates for removal.

Unlike unstructured pruning, which removes individual weights and often creates sparse matrices that need special runtime support, structured pruning removes complete filters or channels. This changes layer dimensions in a way that is more practical for embedded deployment workflows.

The script applies pruning iteratively, retrains the pruned network, and records validation accuracy across sparsity levels. Batch normalization and downstream layer dimensions are adjusted as part of the pruning flow.

## Why Structured Pruning Helps Embedded Deployment

MCU deployment is constrained by Flash, RAM, and available compute. Structured pruning can help because it reduces the size of entire feature maps and layer parameter tensors instead of leaving isolated zero-valued weights.

For resource-constrained systems, this can translate into:

- Smaller model storage requirements.
- Lower intermediate activation memory.
- Reduced computation in convolution layers.
- A model structure that is easier to map to embedded inference code.

The exact benefit depends on the deployment stack, generated code, compiler behavior, and target hardware. This repository preserves documented results from the coursework project rather than claiming a newly reproduced deployment benchmark.

## Quantization Workflow

After pruning, the workflow uses MATLAB quantization tooling to prepare an 8-bit version of the optimized model. The script creates a `dlquantizer` object, calibrates it using a calibration subset, and validates the quantized network against validation data.

Quantization is important for embedded ML because 8-bit weights and activations can reduce memory footprint and may improve inference efficiency on suitable embedded targets. Calibration is part of the process because the quantizer needs representative data to estimate numeric ranges.

## Validation Approach

The documented validation approach compares the model before and after optimization using validation accuracy. The original project notes also include model size, Flash usage, RAM usage, and energy per image as embedded validation metrics.

The repository keeps these metrics in `results/metrics_summary.csv`. They should be read as documented coursework results, not as newly re-run measurements from this cleanup.

## Flash/RAM/Energy/Accuracy Tradeoffs

The main engineering tradeoff is between model quality and embedded resource use:

- Higher accuracy often comes from larger models with more filters and parameters.
- Lower Flash usage is useful because MCU program memory is limited.
- Lower RAM usage matters because activations, buffers, and runtime state compete for limited memory.
- Lower energy per image matters for battery-powered or duty-cycled embedded systems.
- Pruning and quantization can reduce resource use, but excessive optimization can reduce validation accuracy.

The documented results show reduced model size, Flash usage, RAM usage, and energy per image after pruning and quantization, with a lower validation accuracy than the baseline.
