# api
```bash
$ api-code-install              # install vscode swagger visualizer
$ api-open                      # open most recent swagger version (see cli-install-latest)
```

# cert
```bash
$ cert-www                        # open wiki documentation
$ cert-active                     # certificates recently used to decrypt things
$ cert-loaded                     # loaded certificates
$ cert-loaded-by-region           # loaded certificates by region
$ cert-loaded-count               # reported count of loaded certificates
$ cert-active-who $THUMBPRINT     # pods that recently decrypted with a specific version
```

# cli
```bash
$ cli-which                     # no result -> no version installed

$ cli-versions                  # list versions
0.3.2
0.3.1
...

$ cli-install 0.3.1             # download and install a version
$ cli-which
0.3.1

$ cli-install-latest            # install latest
$ cli-which
0.3.2

$ cli-install-previous          # install previous version
$ cli-uninstall                 # uninstall

$ az-dev -h                     # alias for 'az fidalgo dev'
Group
    az fidalgo dev : Manage developer Fidalgo resources.

$ az-admin -h                   # alias for 'az fidalgo admin'
Group
    az fidalgo admin : Manage sadmin Fidalgo resources.
    ...

$ az-attached-network -h
$ az-catalog -h
$ az-catalog-item -h
$ ...                           # All commands aliased
```

# code
```bash
$ PLUGIN=42Crunch.vscode-openapi

$ code-list                     # list vscode plugins
$ code-install $PLUGIN          # download and install vscode plugin
$ code-reinstall $PLUGIN        # uninstall if needed, then download install vscode plugin
$ code-uninstall $PLUGIN        # uninstall vscode plugin
```

# cpc
```bash
$ cpc-open-bug
$ cpc-open-feature
$ cpc-open-dogfood-bug
```

# kusto
```bash
$ cert-loaded-count
$ cert-loaded-count | kusto-compile | kusto-execute | kusto-table
$ cert-loaded-count | kusto-compile | kusto-execute | kusto-focus
$ cert-loaded-count | kusto
```

# test
```bash
$ fd-test-entities                 # dir-name, file-name, parent-dir
$ fd-test-resources                # resources
$ fd-test-activations              # resource activation order

$ test-args                     # "opcodes" options unrelated to identity
$ fd-test-complications            # options unrelated to identity
$ fd-test-roles                    # role assignments

$ fd-test-ids | nl                 # "opcodes" boilerplate (the win); note ~>
$ fd-test-instructions             # "opcodes" unordered
$ fd-test-program                  # "opcodes" ordered

$ fd-test-build                    # the test case, node dogfood registration
```
