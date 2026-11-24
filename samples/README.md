# Sample diagrams

Put test architecture diagrams here (PNG, JPG or single-page PDF), one folder per sample:

```
samples/
  <sample-name>/
    diagram.png          # the input diagram
    deployment.json      # optional: deployment parameters (region, environment, name_prefix, tags)
    expected_ir.json     # added once the extracted IR has been reviewed; used as a golden test
```

Diagrams must not contain real account IDs, hostnames or other sensitive details. They are sent to Amazon Bedrock and stored as evidence.
