# Flow Convert

Powershell script to replace environment specific values in the provided flows


## Purpose

The Common Data Service (Current Environment) is automatically configured to the environment it is imported to, but not all configurations are relevant to a specific environment

Example of configurations that are not specific to the an environment are SharePoint Sites and SharePoint Document Libraries:
- SharePoint Sites are referenced by the URL
- SharePoint Document Libraries are referenced by the library ID

Without replacing the above configuration values, the Flow would be referring to the same SharePoint Site, regardless of which environment it is deployed to


## Replacements file

The replacements file contains the environment specific configurations
- XML is used instead of JSON to avoid awkward `\"` replacements for every `"` inside the find/replace strings

### Example file
```xml
<Replacements>
    <Replacement>
        <Description>SharePoint Site</Description>
        <SourceValue>"https://mytenant.sharepoint.com/sites/MY_SITE_DEV"</SourceValue>
        <TargetValue>"https://mytenant.sharepoint.com/sites/MY_SITE"</TargetValue>
    </Replacement>
    <Replacement>
        <Description>SharePoint Library: Contact entity</Description>
        <SourceValue>"00000000-0000-0000-0000-000000000000"</SourceValue>
        <TargetValue>"11111111-1111-1111-1111-111111111111"</TargetValue>
    </Replacement>
</Replacements>
```

Replacements are done per file, per `<Replacement>` element in the order specified in the file
- This can be beneficial if two values need to be swapped
- Be as specific as possible with the replacements
- The `<Description>` elements are included to help other developers understand where the values come from in case they need to continue another person's work


## Prerequisites

- Find environment specific configurations within the Flow's definition
  - To find the configurations easier, format the Flow JSON with indentation
  - When entering the replacements, replicate the whitespace as found in the original file
- Create replacement file
  - Gather the source environment configuration values
    - Source values should be entered in the `<SourceValue>` nodes
  - Gather the target environment configuration values
    - Target values should be entered in the `<TargetValue>` nodes


## Usage

Example call:
> .\src\flow-convert.ps1 .\input\FlowSolution_1_0_0_0.zip .\src\replacements\example.xml "build\dev"

Parameter descriptions:

| Name                  | Type   | Description |
| --------------------- | ------ | ----------- |
| $solutionZipPath      | string | Relative path to the solution file containing the Flows |
| $replacementsFilePath | string | Path to the replacements XML file to replace with |
| $outputFolder         | string | Output folder to create the updated solution in |
