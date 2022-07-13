resource "aws_instance" "spark" {
  availability_zone = "${var.region}b"
  ami   = "ami-08df646e18b182346" # ap-south-1
  instance_type = "t2.micro"
  tags = {
  Name = "spark"
  }
}

#Create EBS volume and attach with our instance

resource "aws_ebs_volume" "data-vol" {
   availability_zone = "${var.region}b"
   size = 4
   tags = {
     Name = "data-volume"
   }
}

resource "aws_volume_attachment" "spark-vol" {
  device_name = "/dev/sdc"
  volume_id = "${aws_ebs_volume.data-vol.id}"
  instance_id = "${aws_instance.spark.id}"
  depends_on = [
    aws_instance.spark,
    aws_ebs_volume.data-vol
  ]
}