
## MATLAB Workflow

- MATLAB with Deep Learning Toolbox support for CNN training workflows.
- MATLAB APIs used by the script, including `layerGraph`, `dlnetwork`, `minibatchqueue`, `trainingOptions`, `trainNetwork`, `dlquantizer`, `dlquantizationOptions`, `calibrate`, and `validate`.
- Dataset/helper functions referenced by the script, including `loadDigitDataset`, `trainDigitDataNetwork`, `preprocessMiniBatch`, `evaluateAccuracy`, `findConvLayers`, `findBatchNormLayers`, `findFCLayers`, `getConvWeights`, `computeL1Pruning`, and `pruneNetwork`.

## Generated Artifacts

Generated model and quantization files are under `models/` when reproducing the workflow. The script references:

- `models/digitsNet.mat`
- `models/digitsNet_0.90_sparsity_params_6634.mat`
- `models/quantObjPrunedNetworkCalResults.mat`
- `models/quantObjPrunedNetwork.mat`

These files are not committed to the repository.

## Embedded Profiling Context

Simplicity Studio, and Commander/Energy Profiler tooling for Flash, RAM, and energy profiling.
