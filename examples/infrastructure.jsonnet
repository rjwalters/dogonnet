// Infrastructure Dashboard Example
//
// This example shows monitoring for infrastructure resources
// including EC2 instances, load balancers, and databases.

local doggonet = import '../src/doggonet/lib/main.libsonnet';

local layouts = doggonet.layouts;
local widgets = doggonet.widgets;
local presets = doggonet.presets;

layouts.grid(
  'Infrastructure Overview',
  std.flattenArrays([
    // Row 1: Key metrics overview
    layouts.row(0, [
      widgets.queryValue(
        'Total EC2 Instances',
        'count_not_null(avg:aws.ec2.cpuutilization{*} by {instance_id})',
        { autoscale: true }
      ),
      widgets.queryValue(
        'Avg CPU',
        'avg:aws.ec2.cpuutilization{*}',
        { precision: 1, unit: '%' }
      ),
      widgets.queryValue(
        'Avg Memory',
        'avg:system.mem.pct_usable{*}',
        { precision: 1, unit: '%' }
      ),
      widgets.queryValue(
        'Total Network In',
        'sum:aws.ec2.network_in{*}.as_rate()',
        { autoscale: true, unit: 'bytes' }
      ),
    ], height=2),

    // Row 2: CPU and Memory trends
    layouts.row(2, [
      presets.cpuTimeseries(
        'EC2 CPU Utilization',
        'avg:aws.ec2.cpuutilization{*}'
      ),
      presets.memoryTimeseries(
        'Memory Utilization',
        'avg:system.mem.pct_usable{*}'
      ),
    ], height=3),

    // Row 3: Network metrics
    layouts.row(5, [
      widgets.timeseries(
        'Network In',
        'sum:aws.ec2.network_in{*}.as_rate()',
        { display_type: 'area', palette: 'blue' }
      ),
      widgets.timeseries(
        'Network Out',
        'sum:aws.ec2.network_out{*}.as_rate()',
        { display_type: 'area', palette: 'purple' }
      ),
    ], height=3),

    // Row 4: Disk metrics
    layouts.row(8, [
      widgets.timeseries(
        'Disk Usage',
        'avg:system.disk.used{*}',
        { display_type: 'area', palette: 'purple' }
      ),
      widgets.timeseries(
        'Disk I/O',
        ['avg:system.disk.read{*}', 'avg:system.disk.write{*}'],
        { display_type: 'line', show_legend: true }
      ),
      widgets.timeseries(
        'IOPS',
        'sum:aws.ec2.disk_read_ops{*}.as_rate() + sum:aws.ec2.disk_write_ops{*}.as_rate()',
        { display_type: 'bars' }
      ),
    ], height=3),

    // Row 5: Load Balancer metrics
    layouts.row(11, [
      widgets.timeseries(
        'ELB Request Count',
        'sum:aws.elb.request_count{*}.as_rate()',
        { display_type: 'bars' }
      ),
      widgets.timeseries(
        'ELB Latency',
        'avg:aws.elb.latency{*}',
        { display_type: 'line', palette: 'orange' }
      ),
      widgets.timeseries(
        'Healthy Hosts',
        'avg:aws.elb.healthy_host_count{*}',
        { display_type: 'area', palette: 'green' }
      ),
    ], height=3),

    // Row 6: Database metrics
    layouts.row(14, [
      widgets.timeseries(
        'RDS CPU',
        'avg:aws.rds.cpuutilization{*}',
        { display_type: 'line' }
      ),
      widgets.timeseries(
        'RDS Connections',
        'sum:aws.rds.database_connections{*}',
        { display_type: 'area' }
      ),
      widgets.timeseries(
        'RDS Read/Write IOPS',
        ['avg:aws.rds.read_iops{*}', 'avg:aws.rds.write_iops{*}'],
        { display_type: 'line', show_legend: true }
      ),
    ], height=3),

    // Row 7: Top instances by resource usage
    layouts.row(17, [
      widgets.toplist(
        'Top Instances by CPU',
        'avg:aws.ec2.cpuutilization{*} by {instance_id}',
        { limit: 10 }
      ),
      widgets.toplist(
        'Top Instances by Memory',
        'avg:system.mem.pct_usable{*} by {instance_id}',
        { limit: 10 }
      ),
    ], height=4),
  ]),
  {
    description: 'Infrastructure monitoring across EC2, ELB, and RDS',
    tags: ['team:infrastructure', 'type:monitoring'],
  }
)
