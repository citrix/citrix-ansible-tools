#!/usr/bin/python
# -*- coding: utf-8 -*-

DOCUMENTATION = r'''
---
module: citrix_optimizer
short_description: Helps optimize windows environment based on a template
description:
- Helps Citrix administrators optimize various components in their windows environment - most notably operating systems with the Virtual Delivery Agent (VDA) installed
options:
  optimizer_zip_url:
    description:
    - Download link for the citrix optimizer zip file
    type: str
    required: yes
  template_file_name:
    description:
    - The name of the template file to be passed to the optimizer engine, for example "Citrix_Windows_Server_2022_2009"
    type: str
    required: yes
  destination_path:
    description:
    - Path where the optimizer files will be downloaded. By default, they get downloaded to C:\\. The files are removed during the cleanup cycle
    type: str
  retain_logs:
    description:
    - Ensures that the Citrix Optimizer Logs are retained after the cleanup cycle
    - Defaults to False
    type: bool
  force:
    description:
    - Forces the Citrix Optimizer to run irrespective of whether it has been executed previously or not
    - When set to False, if the Citrix Optimizer has been previously run, then it gets skipped in the subsequent runs
    - Defaults to False
    type: bool
'''

EXAMPLES = r'''
- name: Optimizer module
    citrix_optimizer:
        optimizer_zip_url: "{{ citrix_optimizer_zip_url }}"
        template_file_name: "{{citrix_optimizer_template_file_name}}"
        force: True
        retain_logs: True
'''

RETURN = r'''
run_mode:
  description: Mode in which the optimizer was run. Currently, only 'Execute' mode is supported
  returned: always
  type: str
  sample: Execute
run_status:
  description: Indicates whether the optimizer run was successful or not
  returned: always
  type: str
  sample: True
optimizer_version:
  description: Indicates the version of the optimizer engine that was run
  returned: always
  type: str
  sample: 2.9
last_execution_time:
  description: Returns the date and time when the optimizer was last run
  returned: always
  type: str
  sample: 2024-11-01_17-59-53
log_path:
  description: Returns the path where the optimizer logs are stored. Only returned when retain_logs is set to True
  returned: always
  type: str
  sample: C:\\CitrixOptimizerLogs
'''