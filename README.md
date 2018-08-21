# Easy VPC Peering
*更新时间: 2018/08/21*
<br>
<br>
在AWS中国不同区域间快速建立VPC之间的互通

## 说明
![EasyVPN Architedcture](images/EasyVPCPeering.png)

当前AWS中国区域暂时还不支持跨区域VPC Peering, 如果AWS中国宁夏区域和北京区域VPC之间要互联的话，现在可以采用的方式:
1. 基于公网建立Lan-to-Lan VPN
2. 通过AWS Direct Connect 合作伙伴连接
<br>

本方案基于第1种方式，提供基于SSL VPN隧道技术(OpenVPN),快速在AWS中国两个区域之间，建立高可用的VPN通道。

## FAQ
- 问：什么时候用这个方案?<br>
在AWS中国不同区域, 两个网段不重叠的VPC之间，如果需要互联，并且没有计划使用专线方式链接。

- 问：如果AWS中国区域支持跨区域VPC Peering了，还需要这个方案吗? <br>
如果你需要对两个VPC之间的数据有审查或者更加细粒度的控制，例如：访问日志记录，防火墙细则，流量控制。你可能还是需要在两端的基于EC2搭建的VPN服务器上搭建相应的软件或者配置更加细致的规则。

## 操作步骤(TODO)

## 性能测试(TODO)

## 高可用方案(TODO)

## 参考
- [Multiple Region Multi-VPC Connectivity](https://aws.amazon.com/cn/answers/networking/aws-multiple-region-multi-vpc-connectivity/)
- [AWS Cloudformation Templates](https://github.com/awslabs/aws-cloudformation-templates)
- [Using the AWS Command Line Interface](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-using-cli.html)