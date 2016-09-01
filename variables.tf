variable "asg_event_topic_arn" {
  description = "ARN of the topic emitting ASG events"
  type = "string"
}

variable "name" {
  description = "A unique name for this instance"
  type = "string"
  default = "asg-leader-election"
}
