# vagrant-files

## RHEL

for rhel builds I signed up for a [free rhel account](https://developers.redhat.com/blog/2021/02/10/how-to-activate-your-no-cost-red-hat-enterprise-linux-subscription/), downloaded [their iso](https://developers.redhat.com/products/rhel/download), and used [bento's template](https://github.com/chef/bento/tree/master/packer_templates/rhel) to build the vagrant box.

only modification I made was this:


```
"mirror": "file:///path_to_bento_src_parent_dir/bento/packer_templates/"
```

and then dropped my iso in the same folder as the packer template.

Hosting in S3 with presigned link.

activate by running these commands:

```bash
sudo subscription-manager register --username=admin --password=secret
sudo subscription-manager attach --auto
```

currently while writing this my experience was the [vbox provider is broken](https://github.com/chef/bento/issues/1341) for their most recent versions of rhel based distros.
