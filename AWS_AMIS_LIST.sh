#-- CentOS 7 (us-east-1) --

aws ec2 describe-images \
   --owners aws-marketplace \
   --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce \
   --query 'Images[*].[CreationDate,Name,ImageId]' \
   --filters "Name=name,Values=CentOS Linux 7*" \
   --region us-east-1 \
   --output table \
| sort -r

[root@centos-ansible .aws]# aws ec2 describe-images    --owners aws-marketplace    --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce    --query 'Images[*].[CreationDate,Name,ImageId]'    --filters "Name=name,Values=CentOS Linux 7*"    --region us-east-1    --output table | sort -r
|                                                                        DescribeImages                                                                         |
|  2020-03-09T21:49:28.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 2002_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-0042af67f8e4dcc20.4  |  ami-0affd4508a5d2481b  |
|  2019-01-30T23:40:58.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1901_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-05713873c6794f575.4  |  ami-02eac2c0129f6376b  |
|  2018-06-13T15:53:24.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1805_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-77ec9308.4           |  ami-9887c6e7           |
|  2018-05-17T08:59:21.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1804_2-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-55a2322a.4            |  ami-d5bf2caa           |
|  2018-04-04T00:06:30.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1803_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-8274d6ff.4           |  ami-b81dbfc5           |
|  2017-12-05T14:46:53.000Z|  CentOS Linux 7 x86_64 HVM EBS 1708_11.01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-95096eef.4            |  ami-02e98f78           |
+--------------------------+----------------------------------------------------------------------------------------------------------+-------------------------+
+--------------------------+----------------------------------------------------------------------------------------------------------+-------------------------+
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

#-- CentOS 7 (us-east-2) --

aws ec2 describe-images \
   --owners aws-marketplace \
   --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce \
   --query 'Images[*].[CreationDate,Name,ImageId]' \
   --filters "Name=name,Values=CentOS Linux 7*" \
   --region us-east-2 \
   --output table \
| sort -r

[root@centos-ansible .aws]# aws ec2 describe-images    --owners aws-marketplace    --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce    --query 'Images[*].[CreationDate,Name,ImageId]'    --filters "Name=name,Values=CentOS Linux 7*"    --region us-east-2    --output table | sort -r
|                                                                        DescribeImages                                                                         |
|  2020-03-09T21:54:47.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 2002_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-0042af67f8e4dcc20.4  |  ami-01e36b7901e884a10  |
|  2019-01-30T23:43:11.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1901_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-05713873c6794f575.4  |  ami-0f2b4fc905b0bd1f1  |
|  2018-06-13T15:58:32.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1805_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-77ec9308.4           |  ami-9c0638f9           |
|  2018-05-17T09:07:47.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1804_2-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-55a2322a.4            |  ami-77724e12           |
|  2018-04-04T00:13:00.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1803_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-8274d6ff.4           |  ami-994575fc           |
|  2017-12-05T14:48:44.000Z|  CentOS Linux 7 x86_64 HVM EBS 1708_11.01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-95096eef.4            |  ami-e0eac385           |
+--------------------------+----------------------------------------------------------------------------------------------------------+-------------------------+
+--------------------------+----------------------------------------------------------------------------------------------------------+-------------------------+
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

#-- CentOS 7 (us-west-1) --

aws ec2 describe-images \
   --owners aws-marketplace \
   --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce \
   --query 'Images[*].[CreationDate,Name,ImageId]' \
   --filters "Name=name,Values=CentOS Linux 7*" \
   --region us-west-1 \
   --output table \
| sort -r

[root@centos-ansible .aws]# aws ec2 describe-images    --owners aws-marketplace    --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce    --query 'Images[*].[CreationDate,Name,ImageId]'    --filters "Name=name,Values=CentOS Linux 7*"    --region us-west-1    --output table | sort -r
|                                                                        DescribeImages                                                                         |
|  2020-03-09T21:54:49.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 2002_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-0042af67f8e4dcc20.4  |  ami-098f55b4287a885ba  |
|  2019-01-30T23:43:50.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1901_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-05713873c6794f575.4  |  ami-074e2d6769f445be5  |
|  2018-06-13T15:56:29.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1805_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-77ec9308.4           |  ami-4826c22b           |
|  2018-05-17T09:05:26.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1804_2-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-55a2322a.4            |  ami-3b89905b           |
|  2018-04-04T00:11:00.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1803_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-8274d6ff.4           |  ami-78485818           |
|  2017-12-05T14:49:16.000Z|  CentOS Linux 7 x86_64 HVM EBS 1708_11.01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-95096eef.4            |  ami-b1a59fd1           |
+--------------------------+----------------------------------------------------------------------------------------------------------+-------------------------+
+--------------------------+----------------------------------------------------------------------------------------------------------+-------------------------+
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

#-- CentOS 7 (us-west-2) --

aws ec2 describe-images \
   --owners aws-marketplace \
   --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce \
   --query 'Images[*].[CreationDate,Name,ImageId]' \
   --filters "Name=name,Values=CentOS Linux 7*" \
   --region us-west-2 \
   --output table \
| sort -r

[root@centos-ansible .aws]# aws ec2 describe-images    --owners aws-marketplace    --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce    --query 'Images[*].[CreationDate,Name,ImageId]'    --filters "Name=name,Values=CentOS Linux 7*"    --region us-west-2    --output table | sort -r
|                                                                        DescribeImages                                                                         |
|  2020-03-09T21:54:48.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 2002_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-0042af67f8e4dcc20.4  |  ami-0bc06212a56393ee1  |
|  2019-01-30T23:43:37.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1901_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-05713873c6794f575.4  |  ami-01ed306a12b7d1c96  |
|  2018-06-13T15:58:14.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1805_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-77ec9308.4           |  ami-3ecc8f46           |
|  2018-05-17T09:30:44.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1804_2-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-55a2322a.4            |  ami-5490ed2c           |
|  2018-04-04T00:11:39.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1803_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-8274d6ff.4           |  ami-0ebdd976           |
|  2017-12-05T14:49:18.000Z|  CentOS Linux 7 x86_64 HVM EBS 1708_11.01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-95096eef.4            |  ami-b63ae0ce           |
+--------------------------+----------------------------------------------------------------------------------------------------------+-------------------------+
+--------------------------+----------------------------------------------------------------------------------------------------------+-------------------------+
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

#-- CentOS 7 (eu-west-1) --

aws ec2 describe-images \
   --owners aws-marketplace \
   --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce \
   --query 'Images[*].[CreationDate,Name,ImageId]' \
   --filters "Name=name,Values=CentOS Linux 7*" \
   --region eu-west-1 \
   --output table \
| sort -r

[root@centos-ansible .aws]# aws ec2 describe-images    --owners aws-marketplace    --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce    --query 'Images[*].[CreationDate,Name,ImageId]'    --filters "Name=name,Values=CentOS Linux 7*"    --region eu-west-1    --output table | sort -r
|                                                                        DescribeImages                                                                         |
|  2020-03-09T21:54:54.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 2002_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-0042af67f8e4dcc20.4  |  ami-0b850cf02cc00fdc8  |
|  2019-01-30T23:43:59.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1901_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-05713873c6794f575.4  |  ami-0ff760d16d9497662  |
|  2018-06-13T15:56:35.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1805_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-77ec9308.4           |  ami-3548444c           |
|  2018-05-17T09:06:17.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1804_2-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-55a2322a.4            |  ami-4c457735           |
|  2018-04-04T00:13:35.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1803_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-8274d6ff.4           |  ami-1caef165           |
|  2017-12-05T14:49:45.000Z|  CentOS Linux 7 x86_64 HVM EBS 1708_11.01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-95096eef.4            |  ami-192a9460           |
+--------------------------+----------------------------------------------------------------------------------------------------------+-------------------------+
+--------------------------+----------------------------------------------------------------------------------------------------------+-------------------------+
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

#-- CentOS 7 (eu-west-2) --

aws ec2 describe-images \
   --owners aws-marketplace \
   --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce \
   --query 'Images[*].[CreationDate,Name,ImageId]' \
   --filters "Name=name,Values=CentOS Linux 7*" \
   --region eu-west-2 \
   --output table \
| sort -r

[root@centos-ansible .aws]# aws ec2 describe-images    --owners aws-marketplace    --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce    --query 'Images[*].[CreationDate,Name,ImageId]'    --filters "Name=name,Values=CentOS Linux 7*"    --region eu-west-2    --output table | sort -r
|                                                                        DescribeImages                                                                         |
|  2020-03-09T21:54:47.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 2002_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-0042af67f8e4dcc20.4  |  ami-09e5afc68eed60ef4  |
|  2019-01-30T23:43:42.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1901_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-05713873c6794f575.4  |  ami-0eab3a90fc693af19  |
|  2018-06-13T15:56:40.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1805_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-77ec9308.4           |  ami-00846a67           |
|  2018-05-17T09:02:51.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1804_2-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-55a2322a.4            |  ami-4726cb20           |
|  2018-04-04T00:10:11.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1803_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-8274d6ff.4           |  ami-4f02e328           |
|  2017-12-05T14:48:38.000Z|  CentOS Linux 7 x86_64 HVM EBS 1708_11.01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-95096eef.4            |  ami-c8d7c9ac           |
+--------------------------+----------------------------------------------------------------------------------------------------------+-------------------------+
+--------------------------+----------------------------------------------------------------------------------------------------------+-------------------------+
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

#-- CentOS 7 - Asia Pacific (Singapore) ap-southeast-1 --

aws ec2 describe-images \
   --owners aws-marketplace \
   --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce \
   --query 'Images[*].[CreationDate,Name,ImageId]' \
   --filters "Name=name,Values=CentOS Linux 7*" \
   --region ap-southeast-1 \
   --output table \
| sort -r

[root@centos-ansible .aws]# aws ec2 describe-images    --owners aws-marketplace    --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce    --query 'Images[*].[CreationDate,Name,ImageId]'    --filters "Name=name,Values=CentOS Linux 7*"    --region ap-southeast-1    --output table | sort -r
|                                                                        DescribeImages                                                                         |
|  2020-03-09T21:54:51.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 2002_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-0042af67f8e4dcc20.4  |  ami-07f65177cb990d65b  |
|  2019-01-30T23:45:14.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1901_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-05713873c6794f575.4  |  ami-0b4dd9d65556cac22  |
|  2018-06-13T15:58:32.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1805_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-77ec9308.4           |  ami-8e0205f2           |
|  2018-05-17T09:06:00.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1804_2-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-55a2322a.4            |  ami-da6151a6           |
|  2018-04-04T00:14:34.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1803_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-8274d6ff.4           |  ami-16a4fe6a           |
|  2017-12-05T14:49:45.000Z|  CentOS Linux 7 x86_64 HVM EBS 1708_11.01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-95096eef.4            |  ami-a6e88dda           |
+--------------------------+----------------------------------------------------------------------------------------------------------+-------------------------+
+--------------------------+----------------------------------------------------------------------------------------------------------+-------------------------+
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

#-- CentOS 7 (ap-southeast-2) --

aws ec2 describe-images \
   --owners aws-marketplace \
   --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce \
   --query 'Images[*].[CreationDate,Name,ImageId]' \
   --filters "Name=name,Values=CentOS Linux 7*" \
   --region ap-southeast-2 \
   --output table \
| sort -r

[root@centos-ansible .aws]# aws ec2 describe-images    --owners aws-marketplace    --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce    --query 'Images[*].[CreationDate,Name,ImageId]'    --filters "Name=name,Values=CentOS Linux 7*"    --region ap-southeast-2    --output table | sort -r
|                                                                        DescribeImages                                                                         |
|  2020-03-09T21:54:50.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 2002_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-0042af67f8e4dcc20.4  |  ami-0b2045146eb00b617  |
|  2019-01-30T23:45:27.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1901_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-05713873c6794f575.4  |  ami-08bd00d7713a39e7d  |
|  2018-06-13T15:59:00.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1805_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-77ec9308.4           |  ami-d8c21dba           |
|  2018-05-17T09:05:34.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1804_2-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-55a2322a.4            |  ami-0d13c26f           |
|  2018-04-04T00:13:03.000Z|  CentOS Linux 7 x86_64 HVM EBS ENA 1803_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-8274d6ff.4           |  ami-dda36dbf           |
|  2017-12-05T14:49:22.000Z|  CentOS Linux 7 x86_64 HVM EBS 1708_11.01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-95096eef.4            |  ami-5b778339           |
+--------------------------+----------------------------------------------------------------------------------------------------------+-------------------------+
+--------------------------+----------------------------------------------------------------------------------------------------------+-------------------------+
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

#-- Red Hat 7 --

aws ec2 describe-images \
  --owners 309956199498 \
  --query 'Images[*].[CreationDate,Name,ImageId]' \
  --filters "Name=name,Values=RHEL-7.?*GA*" \
  --region us-east-1 \
  --output table \
| sort -r

[root@centos-ansible .aws]# aws ec2 describe-images   --owners 309956199498   --query 'Images[*].[CreationDate,Name,ImageId]'   --filters "Name=name,Values=RHEL-7.?*GA*"   --region us-east-1   --output table | sort -r
|                                            DescribeImages                                            |
|  2020-09-18T07:51:03.000Z |  RHEL-7.9_HVM_GA-20200917-x86_64-0-Hourly2-GP2  |  ami-005b7876121b7244d |
|  2020-02-26T16:54:07.000Z |  RHEL-7.8_HVM_GA-20200225-x86_64-1-Hourly2-GP2  |  ami-08e923f2f38197e46 |
|  2019-07-24T08:49:05.000Z |  RHEL-7.7_HVM_GA-20190723-x86_64-1-Hourly2-GP2  |  ami-0916c408cb02e310b |
|  2019-01-28T16:48:05.000Z |  RHEL-7.6_HVM_GA-20190128-x86_64-0-Hourly2-GP2  |  ami-000db10762d0c4c05 |
|  2018-11-22T23:42:05.000Z |  RHEL-7.6_HVM_GA-20181122-arm64-0-Hourly2-GP2   |  ami-0e3688b4a755ad736 |
|  2018-10-17T13:13:44.000Z |  RHEL-7.6_HVM_GA-20181017-x86_64-0-Hourly2-GP2  |  ami-011b3ccf1bd6db744 |
|  2018-03-23T20:42:08.000Z |  RHEL-7.5_HVM_GA-20180322-x86_64-1-Hourly2-GP2  |  ami-6871a115          |
|  2017-08-08T15:37:31.000Z |  RHEL-7.4_HVM_GA-20170808-x86_64-2-Hourly2-GP2  |  ami-c998b6b2          |
|  2017-07-24T15:44:39.000Z |  RHEL-7.4_HVM_GA-20170724-x86_64-1-Hourly2-GP2  |  ami-cdc999b6          |
|  2016-10-26T22:32:29.000Z |  RHEL-7.3_HVM_GA-20161026-x86_64-1-Hourly2-GP2  |  ami-b63769a1          |
|  2015-11-12T21:06:58.000Z |  RHEL-7.2_HVM_GA-20151112-x86_64-1-Hourly2-GP2  |  ami-2051294a          |
|  2015-02-25T20:24:23.000Z |  RHEL-7.1_HVM_GA-20150225-x86_64-1-Hourly2-GP2  |  ami-12663b7a          |
|  2015-02-09T22:54:40.000Z |  RHEL-7.0_HVM_GA-20150209-x86_64-1-Hourly2-GP2  |  ami-60a1e808          |
|  2014-10-17T20:29:24.000Z |  RHEL-7.0_HVM_GA-20141017-x86_64-1-Hourly2-GP2  |  ami-a8d369c0          |
|  2014-05-28T19:17:11.000Z |  RHEL-7.0_GA_HVM-x86_64-3-Hourly2               |  ami-785bae10          |
+---------------------------+-------------------------------------------------+------------------------+
+---------------------------+-------------------------------------------------+------------------------+
--------------------------------------------------------------------------------------------------------
