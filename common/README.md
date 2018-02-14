# common Cookbook

This cookbook installs the wordpress, mysql, influxdb, grafana and telegraf containers.


## Requirements

It depends on chef community provided docker cookbook to manage the docker containers.

e.g.
### Platforms

- SandwichOS

### Chef

- Chef 12.5 or later

### Cookbooks

- `toaster` - common needs toaster to brown your bagel.

## Attributes

TODO: List your cookbook attributes here.

e.g.
### common::default

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['common']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### common::default

TODO: Write usage instructions for each cookbook.

e.g.
Just include `common` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[common]"
  ]
}
```

## Contributing

TODO: (optional) If this is a public cookbook, detail the process for contributing. If this is a private cookbook, remove this section.

e.g.
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License and Authors

Authors: Manish Joshi

