variable "aws_region" {}

variable "cidr_block" {}

variable "vpc_first_octet" {
  default = "172"
}

variable "vpc_name" {
  default = "infra"
}

variable "vpc_second_octet" {}

data "aws_vpc" "default" {
  default = true
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "subnet_private_a" {
  value = "${module.subnet_private_a.subnet_id}"
}

output "subnet_private_b" {
  value = "${module.subnet_private_b.subnet_id}"
}

output "subnet_private_c" {
  value = "${module.subnet_private_c.subnet_id}"
}

output "nat_id" {
  value = "${module.nat_private.nat_id}"
}

output "eip_nat" {
 value = "${module.eip_nat.eip_public_ip}"
}

module "vpc" {
  cidr_block = "${var.cidr_block}"
  vpc_name   = "${var.vpc_name}"
  source     = "github.com/Trility/tf-aws-modules//vpc"
}

module "route_table_public" {
  vpc_id  = "${module.vpc.vpc_id}"
  rt_name = "${var.vpc_name}-public"
  source  = "github.com/Trility/tf-aws-modules//route_table"
}

module "route_table_private" {
  vpc_id  = "${module.vpc.vpc_id}"
  rt_name = "${var.vpc_name}-private"
  source  = "github.com/Trility/tf-aws-modules//route_table"
}

module "igw" {
  vpc_id   = "${module.vpc.vpc_id}"
  igw_name = "${var.vpc_name}"
  source   = "github.com/Trility/tf-aws-modules//internet_gateway"
}

module "subnet_public_a" {
  availability_zone = "${var.aws_region}a"
  map_public_ip     = "true"
  subnet_cidr_block = "${var.vpc_first_octet}.${var.vpc_second_octet}.2.0/24"
  subnet_name       = "${var.vpc_name}-public-aza"
  vpc_id            = "${module.vpc.vpc_id}"
  source            = "github.com/Trility/tf-aws-modules//subnet"
}

module "subnet_public_b" {
  availability_zone = "${var.aws_region}b"
  subnet_cidr_block = "${var.vpc_first_octet}.${var.vpc_second_octet}.4.0/24"
  subnet_name       = "${var.vpc_name}-public-azb"
  map_public_ip     = "true"
  vpc_id            = "${module.vpc.vpc_id}"
  source            = "github.com/Trility/tf-aws-modules//subnet"
}

module "subnet_public_c" {
  availability_zone = "${var.aws_region}c"
  subnet_cidr_block = "${var.vpc_first_octet}.${var.vpc_second_octet}.6.0/24"
  subnet_name       = "${var.vpc_name}-public-azc"
  map_public_ip     = "true"
  vpc_id            = "${module.vpc.vpc_id}"
  source            = "github.com/Trility/tf-aws-modules//subnet"
}

module "subnet_private_a" {
  vpc_id            = "${module.vpc.vpc_id}"
  subnet_name       = "${var.vpc_name}-private-aza"
  subnet_cidr_block = "${var.vpc_first_octet}.${var.vpc_second_octet}.1.0/24"
  availability_zone = "${var.aws_region}a"
  source            = "github.com/Trility/tf-aws-modules//subnet"
}

module "subnet_private_b" {
  vpc_id            = "${module.vpc.vpc_id}"
  subnet_name       = "${var.vpc_name}-private-azb"
  subnet_cidr_block = "${var.vpc_first_octet}.${var.vpc_second_octet}.3.0/24"
  availability_zone = "${var.aws_region}b"
  source            = "github.com/Trility/tf-aws-modules//subnet"
}

module "subnet_private_c" {
  vpc_id            = "${module.vpc.vpc_id}"
  subnet_name       = "${var.vpc_name}-private-azc"
  subnet_cidr_block = "${var.vpc_first_octet}.${var.vpc_second_octet}.5.0/24"
  availability_zone = "${var.aws_region}c"
  source            = "github.com/Trility/tf-aws-modules//subnet"
}

module "route_table_association_public_aza" {
  subnet_id      = "${module.subnet_public_a.subnet_id}"
  route_table_id = "${module.route_table_public.route_table_id}"
  source         = "github.com/Trility/tf-aws-modules//route_table_association"
}

module "route_table_association_public_azb" {
  subnet_id      = "${module.subnet_public_b.subnet_id}"
  route_table_id = "${module.route_table_public.route_table_id}"
  source         = "github.com/Trility/tf-aws-modules//route_table_association"
}

module "route_table_association_public_azc" {
  subnet_id      = "${module.subnet_public_c.subnet_id}"
  route_table_id = "${module.route_table_public.route_table_id}"
  source         = "github.com/Trility/tf-aws-modules//route_table_association"
}

module "route_table_association_private_aza" {
  subnet_id      = "${module.subnet_private_a.subnet_id}"
  route_table_id = "${module.route_table_private.route_table_id}"
  source         = "github.com/Trility/tf-aws-modules//route_table_association"
}

module "route_table_association_private_azb" {
  subnet_id      = "${module.subnet_private_b.subnet_id}"
  route_table_id = "${module.route_table_private.route_table_id}"
  source         = "github.com/Trility/tf-aws-modules//route_table_association"
}

module "route_table_association_private_azc" {
  subnet_id      = "${module.subnet_private_c.subnet_id}"
  route_table_id = "${module.route_table_private.route_table_id}"
  source         = "github.com/Trility/tf-aws-modules//route_table_association"
}

module "eip_nat" {
  source = "github.com/Trility/tf-aws-modules//eip"
}

module "nat_private" {
  allocation_id = "${module.eip_nat.eip_id}"
  subnet_id     = "${module.subnet_public_a.subnet_id}"
  source        = "github.com/Trility/tf-aws-modules//nat_gateway"
}

module "vpc_s3_endpoint" {
  vpc_id          = "${module.vpc.vpc_id}"
  route_table_ids = ["${module.route_table_public.route_table_id}", "${module.route_table_private.route_table_id}"]
  source          = "github.com/Trility/tf-aws-modules//vpc_endpoint"
}

module "route_igw" {
  route_table_id         = "${module.route_table_public.route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gw_id                  = "${module.igw.igw_id}"
  source                 = "github.com/Trility/tf-aws-modules//route_gw"
}

module "route_nat" {
  route_table_id         = "${module.route_table_private.route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gw_id              = "${module.nat_private.nat_id}"
  source                 = "github.com/Trility/tf-aws-modules//route_nat"
}

module "sg_ssh" {
  group_name        = "${var.vpc_name}-ssh"
  group_description = "${var.vpc_name}-ssh"
  vpc_id            = "${module.vpc.vpc_id}"
  source            = "github.com/Trility/tf-aws-modules//sg"
}

module "sg_ssh_rule" {
  rule_type   = "ingress"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["${var.cidr_block}"]
  sg_id       = "${module.sg_ssh.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}

module "sg_ssh_egress" {
  rule_type   = "egress"
  from_port   = 0
  to_port     = 65535
  cidr_blocks = ["0.0.0.0/0"]
  protocol    = "all"
  sg_id       = "${module.sg_ssh.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}

module "sg_rdp" {
  group_name        = "${var.vpc_name}-rdp"
  group_description = "${var.vpc_name}-rdp"
  vpc_id            = "${module.vpc.vpc_id}"
  source            = "github.com/Trility/tf-aws-modules//sg"
}

module "sg_rdp_rule" {
  rule_type   = "ingress"
  from_port   = 3389
  to_port     = 3389
  cidr_blocks = ["${var.cidr_block}"]
  sg_id       = "${module.sg_rdp.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}

module "sg_rdp_egress" {
  rule_type   = "egress"
  from_port   = 0
  to_port     = 65535
  cidr_blocks = ["0.0.0.0/0"]
  protocol    = "all"
  sg_id       = "${module.sg_rdp.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}
