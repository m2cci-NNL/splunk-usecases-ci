#!/usr/bin/env python3
import sys, pathlib, yaml
base = pathlib.Path(sys.argv[1])
stanzas = []
for y in base.rglob('correlation_searches/*.yml'):
    data = yaml.safe_load(open(y))
    title = data['name']
    search = " ".join(line.strip() for line in str(data['search']).splitlines() if line.strip())
    cron = data.get('cron_schedule','*/10 * * * *')
    earliest = data.get('earliest_time','-15m')
    latest = data.get('latest_time','now')
    severity = data.get('severity','medium')
    stanzas.append(f"""[{title}]
search = {search}
cron_schedule = {cron}
dispatch.earliest_time = {earliest}
dispatch.latest_time = {latest}
action.notable = 1
action.notable.param.rule_title = {title}
action.notable.param.severity = {severity}
""")
print("\n".join(stanzas))
