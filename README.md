AWS AutoScaling Group Leader Election
-------------------------------------

This terraform module provides a lambda function, which will elect a "leader"
instance when receiving an auto scaling event from the specified SNS topic.

The "leader" is a single available instance within the AutoScaling Group which
receives a special tag. This is similar to ElasticBeanstalk's concept of a
"master" instance, and is useful for scenarios when you need to give a single
machine control over the entire cluster, or execute actions only on one machine.
