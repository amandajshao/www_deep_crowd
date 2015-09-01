# -*- coding:utf-8 -*-
"""
Run GKLT tracker sequentially on many video frames
"""

class Simulator:
    '''
    Execute multiple missions using python in windows.
    '''
    def __init__(self):
        self.cmds = []
        self.paths = []
        
    def isExist(self, cmd):
        sz = self.cmds.__len__()
        for i in xrange(sz):
            if cmd == self.cmds[i]:
                return i
        return -1

    def registe(self, names_paths):
        '''
        add a application into 
        list.
        '''
        for item in names_paths.items():
            if self.isExist(item[0]) != -1:
                print "CMD %s exists, "\
                    "please rename to anothe one." \
                    % item[0]
            else:
                self.cmds.append(item[0])
                self.paths.append(item[1])

    def run(self, cmd, args="", inShell=True):
        '''
        run a command
        '''
        from subprocess import check_call
        
        # get original module 
        idx = self.isExist(cmd)
        if idx == -1:
            print "CMD %s not exists!" % cmd 
            return None
        #print [self.paths[idx], args]
        args = args.split()
        return check_call([self.paths[idx]] + args,shell = inShell)

class Helper:
    def listsubfolders(self, root):
        from os import listdir, path
        subfolders = [ path.join(root,f) for f in listdir(root) ]
        subfolders = [ f for f in subfolders if True == path.isdir(f) ]
        return subfolders

    def genimgnamelist(self,folders):
        from os import listdir,path
        nums = []
        name = "imageList.txt"
        for f in folders:
            #print f
            imgs = [n for n in listdir(f) if n.endswith('.jpg')]
            pf = open(path.join(f,name), "w")
            pf.write('\n'.join(imgs))
            nums.append(len(imgs))
        return nums
        
if __name__ == '__main__':

    # get all subfolders and generate all imgList.txt
    h = Helper()
    folders = h.listsubfolders("D:\\code\\release_collectiveness\\tracker_bin")
    # the folder contains the folders of video frames
    nums = h.genimgnamelist(folders)
    
    # resigster module
    # right command 
    # then do it.
    s = Simulator()
    
    exe0 = {"klt":"D:\\code\\release_collectiveness\\tracker_bin\\klt_tracker.exe"}
    
    s.registe(exe0)

    sz = len(folders)
    nFeature = 3000
    scale = 10 # real_scale = (scale / 10)
    backgroundthreshold = 16
    for i in range(sz):
        print "processing clip in %s contains %d images..." % (folders[i], nums[i])
        args = "%s %d %d %d %d" % (folders[i] + "\\", nums[i], nFeature, scale, backgroundthreshold)
        # args_silent = "%s %d %d %d %d %d" % (folders[i] + "\\", nums[i], nFeature, scale, backgroundthreshold, 0)
        # if you want to observe results
        s.run("klt", args)
        # or if you want to process images silentlt & fast
        # s.run("klt", args_silent)
        
    #for i in range(sz):
    #    print "processing clip in %s contains %d images..." % (folders[i], nums[i])
    #    args = "%s %d" % (folders[i] + "\\", nums[i])
    #    s.run("klt_half", args)
        
    print "Done!"
