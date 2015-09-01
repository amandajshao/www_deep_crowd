# Deeply Learned Attributes for Crowded Scene Understanding


This is the source code for ["Deeply Learned Attributes for Crowded Scene Understanding"](http://www.ee.cuhk.edu.hk/~jshao/papers_jshao/jshao_cvpr15_www.pdf).


### Features

> Two-branch CNN model (i.e. appearance branch and motion branch)
>
> Multi-class (i.e. 94 crowd attributes)


### Files

> [Caffe Model](https://www.dropbox.com/sh/1j5ucqmuvgirbsj/AAAesGjrqVatk8EB3WGea26ka?dl=0)

	Three models: 
		single-branch (appearance model) `data_rgb_all_www_model_upgrade.caffemodel`
		single-branch (motion model) `data_motion_all_www_model_upgrade.caffemodel`
		two-branch (fusing appearance and motion models) `data_rgbm_all_www_top_combine_model_upgrade.caffemodel`

> [Prototxt](https://www.dropbox.com/s/rdkbjhcdx5sa0o3/data_rgbm_all_www_deploy_top_combine_upgrade.prototxt?dl=0)

> Motion channels

> [Training Data Splits](http://www.ee.cuhk.edu.hk/~jshao/WWWcrowd_files/www_archive.zip)

> [Project Site](http://www.ee.cuhk.edu.hk/~jshao/WWWCrowdDataset.html)


## Citation

J. Shao, K. Kang, C. C. Loy, and X. Wang
Deeply Learned Attributes for Crowded Scene Understanding.
_Computer Vision and Pattern Recognition (CVPR), 2015_.

	@article{shao2015www,
	  title={Deeply learned attributes for crowded scene understanding},
  	  author={Shao, Jing and Kang, Kai and Loy, Chen Change and Wang, Xiaogang},
  	  booktitle={Computer Vision and Pattern Recognition (CVPR)},
  	  year={2015}
	}
