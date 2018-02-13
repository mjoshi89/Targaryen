# targaryen

This repository if to bring up a wordpress server along with a monitoring server.

You can use the cloudformation template to bring up all the required resources for the same. The cloudformation will spin up a t2-medium instance and with the help of chef recepies it'll install wordpress + mysql container as well as telgraf + influxdb + grafana containers.

It is easy to scale up this solution to separate out the different layers but I haven't done that considering the cost involved.

As an ideal or the next step to this solution would be to separte the mysql container into a RDS instance perhaps, move the influxdb and grafana containers separately and let telegraf run on the other servers where we want to monitor the containers and send the metrics to influxdb(ofcourse we'll need a route53 domain perhaps for this to make sure we update the influxdb url in there and let all the telgraf containers point to that entry using chef.) Wer can also use EFS if we want to have HA for our wordpress servers.
