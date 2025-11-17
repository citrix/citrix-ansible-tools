locals {
  lines = split("\n", data.local_file.key_values.content)
  key_value_map = { for line in local.lines :
                     element(split(":", line), 0) => element(split(":", line), 1)
                   }
}