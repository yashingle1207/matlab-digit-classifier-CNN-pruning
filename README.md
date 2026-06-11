# MATLAB CNN Optimization for EFM32 MCU Deployment

Maintained by: Yash Daniel Ingle

The project focuses on optimizing a small CNN for digit classification using MATLAB, then evaluating the model with an embedded ML mindset for MCU deployment on the EFM32GG11 platform. The repository preserves the existing source, documented metrics, and profiling screenshots from the coursework project without adding new hardware claims or re-created results.

## Overview

The work explores how a neural network can be made more suitable for resource-constrained systems through model optimization techniques such as pruning and quantization. The MATLAB workflow trains a digit-classification CNN, applies structured pruning, performs post-training quantization, and compares the documented effects on accuracy, model size, Flash/RAM usage, and energy per image.

The embedded validation context is EFM32GG11 MCU deployment, with profiling artifacts showing before/after resource measurements from the original project materials.

## Why This Project Matters

Embedded ML is not only about getting a model to run. It is about making the model fit within real hardware limits: memory, storage, energy, and deployment tooling. This project was useful because it connected CNN optimization in MATLAB with hardware-aware validation for an MCU-class target.

The coursework helped demonstrate the tradeoff between model accuracy and embedded constraints, especially where Flash/RAM profiling and energy profiling matter as much as validation accuracy.

## System Workflow

```text
Digit dataset
    |
    v
Train CNN in MATLAB
    |
    v
Evaluate baseline accuracy
    |
    v
Apply L1-norm structured pruning
    |
    v
Retrain and evaluate pruned model
    |
    v
Apply post-training quantization
    |
    v
Collect documented model/resource metrics
    |
    v
Review EFM32GG11 profiling screenshots
```

## Repository Structure

```text
.
|-- README.md
|-- LICENSE
|-- requirements.md
|-- src/
|   `-- pruning_quantization_digitsNet.m
|-- results/
|   |-- README.md
|   |-- metrics_summary.csv
|   |-- ProfilingBeforePruning.png
|   |-- ProfilingAfterPruning.png
|   |-- pruning_accuracy_trend.png       (generated when the MATLAB workflow is run)
|   `-- layer_filter_pruning.png        (generated when the MATLAB workflow is run)
|-- docs/
|   |-- methodology.md
|   |-- profiling_notes.md
|   |-- diagnostic_state_machine_concept.md
|   `-- original_README.md
`-- models/
    `-- README.md
```

## Tools and Technologies

- MATLAB
- MATLAB Deep Learning Toolbox workflows
- `dlquantizer` and post-training quantization APIs
- CNN pruning and model optimization
- EFM32GG11 MCU deployment context
- Simplicity Studio / Commander tooling as documented in the original project notes
- Flash/RAM profiling and energy profiling
- Technical documentation for embedded ML and resource-constrained systems

## Methodology

The MATLAB script in `src/` follows the original coursework workflow:

1. Load the digit dataset and train a CNN baseline.
2. Evaluate the original network accuracy.
3. Identify convolution, batch normalization, and fully connected layers.
4. Apply iterative L1-norm structured pruning to remove lower-importance filters.
5. Retrain after pruning iterations and track validation accuracy.
6. Quantize the pruned model using MATLAB quantization tooling.
7. Save generated model and quantization artifacts locally under `models/`.

Generated `.mat` files are not committed to the repository. See `models/README.md` for details.

For more detail, see `docs/methodology.md`.

## Results

These metrics come from the original project documentation and are also available in `results/metrics_summary.csv`. They were not re-measured during repository cleanup.

| Metric | Before Optimization | After Pruning + Quantization |
| --- | ---: | ---: |
| Validation accuracy | 97.5% | 92.1% |
| Model size | 27.5 KB | 18.3 KB |
| Flash usage | 23.4 KB | 16.2 KB |
| RAM usage | 7.2 KB | 4.9 KB |
| Energy per image | 7.43 uJ | 4.91 uJ |
| Sparsity achieved | Not recorded | 90% |

## Profiling Screenshots

Before pruning:

![Profiling before pruning](results/ProfilingBeforePruning.png)

After pruning:

![Profiling after pruning](results/ProfilingAfterPruning.png)

Additional context is documented in `docs/profiling_notes.md`.

## How to Run

Open MATLAB from the repository root.
Add the source folder to the MATLAB path:
    addpath(genpath('src'))

Run the main workflow:
    run('src/pruning_quantization_digitsNet.m')

The script trains the digit-classification CNN, applies iterative L1-norm pruning, validates the pruned model, generates pruning/accuracy plots, and runs the quantization workflow when the generated pruned model artifact is available in models/.

Generated .mat model files are intentionally excluded from the repository to keep it lightweight. Hardware resource and energy profiling results from the EFM32GG11 workflow are included in results/ for reference.

## My Contributions

- MATLAB pruning/quantization workflow.
- Model evaluation before and after optimization.
- Flash/RAM/accuracy/energy tradeoff analysis.
- Documentation and profiling comparison.
- Cleanup for portfolio use.

## Engineering Takeaways

- Model optimization for MCU deployment requires more than accuracy tracking.
- Pruning and quantization can reduce memory and storage requirements, but they must be checked against validation accuracy.
- Flash/RAM profiling and energy profiling are important parts of hardware-aware validation.
- Embedded ML workflows benefit from clear separation between source code, generated artifacts, measured results, and documentation.
- Resource-constrained systems force practical tradeoffs that are easy to miss in desktop-only ML experiments.

## Future Improvements

- Add a small sample inference workflow that can run without hardware.
- Explore the future MCU diagnostic state-machine concept described in `docs/diagnostic_state_machine_concept.md`.

## License

This project is released under the MIT License. See `LICENSE` for details.
