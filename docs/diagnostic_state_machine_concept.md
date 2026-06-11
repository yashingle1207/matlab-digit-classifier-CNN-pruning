# Diagnostic State Machine Concept

This document describes a possible future MCU diagnostic flow for an embedded ML application. It is a concept document only.

It is not completed work, not an implemented firmware feature, and not a completed Simulink model. It is included as a future extension idea for how an optimized CNN deployment could be wrapped in a safer embedded runtime flow.

## Concept Flow

```text
INIT
  |
  v
LOAD_MODEL
  |
  v
IDLE
  |
  v
RUN_INFERENCE
  |
  v
CHECK_CONFIDENCE
  |
  v
REPORT_STATUS
  |
  v
SAFE_MODE
```

## State Descriptions

### INIT

Initialize clocks, memory, peripherals, logging hooks, and any runtime buffers needed by the MCU application.

### LOAD_MODEL

Load or verify the optimized model artifact. In a production firmware flow, this state could check model version, memory availability, and basic integrity before inference is enabled.

### IDLE

Wait for an input sample, sensor event, command, or scheduled inference trigger. This state can help reduce energy consumption by avoiding unnecessary inference work.

### RUN_INFERENCE

Run the CNN inference path on the current input. This is where pruning and quantization would matter most for latency, Flash usage, RAM usage, and energy use.

### CHECK_CONFIDENCE

Evaluate the model output confidence or classification margin. A low-confidence result could trigger a diagnostic status instead of treating the prediction as reliable.

### REPORT_STATUS

Report the classification result, confidence category, resource status, or diagnostic code to the surrounding system.

### SAFE_MODE

Enter a conservative fallback state if model loading fails, memory checks fail, confidence remains too low, or the system detects an unsafe runtime condition.

## Future Work Needed

To turn this concept into completed work, the project would need:

- Actual embedded firmware implementation.
- Defined confidence thresholds.
- Error-handling behavior for each transition.
- Hardware-specific memory and timing checks.
- A test plan for normal and fault-state behavior.
- Optional Simulink modeling only if a real model-based design workflow is added later.
