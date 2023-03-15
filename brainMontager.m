function [im,cont,m1,m2] = brainMontager(inFU,inFO,sls,uBin,uLim,uCmpNm,uThr,backClr,maskOF,oBin,oLim,oCmpNm,oThr,oAlpha,vAng,contr,useRawLims)
% Generates a montage of brains on a tile chart using an overlay and an
% underlay. The underlay may be turned into a contour map (currently only
% tested with 8mm and 4mm segmentation maps). 
%
% Inputs -------------------------------------------
% inFU: path (char) to a nifti file that will be the underlay or background
%
% inFO: path (char) to a nifti file that will be the overlay or foreground
%
% sls: which sagittal slices to plot (whole integers in a vector) corresponding to z-dim
%       indices
% uBin: how many  bins to have for the underlay colormap
%
% uLim: limits for the underlay colormap as a 1 x 2 vector
%
% uCmpNm: an internal matlab colormap, or the name of any other
%       colormap redistributed with brainSurfer (or made by you according
%       to brainSurfer friednly formats) to use for the underlay: 'jet',
%       parula, hsv, hot, cool, spring, summer, autumn, winter, gray, bone,
%       copper, pink, lines, colorcube, prism, spectral, RdYlBu, RdGy,
%       RdBu, PuOr, PRGn, PiYG, BrBG, YlOrRd, YlOrBr, YlGnBu, YlGn, Reds,
%       RdPu, Purples, PuRd, PuBuGn, PuBu, OrRd, oranges, greys, greens,
%       GnBu, BuPu, BuGn, blues, set3, set2, set1, pastel2, pastel1,
%       paired, dark2, accent, inferno, plasma, vega10, vega20b, vega20c,
%       viridis, thermal, haline, solar, ice, oxy, deep, dense, algae,
%       matter, turbid, speed, amp, tempo, balance, delta, curl, phase,
%       perceptually distinct (default is jet).
%       
%       colormap can also be an l x 3 matrix of colors specifying a custom
%       colormap
%
% uThr: threshold for the underlay data specified as a 1 x 2 vector
%
% backClr: background color as a 1 x 3 vector (rgb)
%
% maskOF: if true, overlay will be masked by all non-zero underlay voxels
%
% oBin: how many bins for the overlay colormap
%
% oLim: limits for the underlay colormap as a 1 x 2 vector
%
% oCmpNm: colormap for the overlay (see uCmpNm)
%
% oThr: threshold for the overlay data specified as a 1 x 2 vector
%
% oAlpha: transparency for the overlay map (number between 0 and 1)
%
% vAng: rotation of tiles. Set to 'l' to show default arrangement
% (and where left side will be on left for contoured maps). Set to 'ud' to
% have tiles go up down, then left right.
%
% contr: if true, overlay will be opaque with contours of the underlay
% superimposed. If false, overlay and underlay will both be plotted as they
% are. 
%
% useRawLims: if true limits will be based on min and max of image. If
% false, limits will be set to negative and positive of max value in image only if there are
% both positive and negative values OR the limits will be zero and max value in image if there are no negative values
% in the map.
%
% lvls: levels to keep for the contour map. Default is [0.5 1.5 2.5 3.5]
%
% EXAMPLE CALL: [~,~,~,~] = brainMontager(structural.nii.gz,'functional.nii.gz',...
% [],5,[],'gray',[],[1 1 1],true,1000,[],'jet',[],0.3,'ud',true,false);
%
%
% Outputs -------------------------------------------
% im: cell of overlay figures
% cont: cell of contour figures
% m1: underlay montage
% m2: overlay montage
%
% Send bugs to alex.teghipco@sc.edu

im = []; cont = []; m1 = []; m2 = [];
if isempty(backClr)
    backClr = [1 1 1];
end
if isempty(oAlpha)
   oAlpha = 0.3; 
end

%if isempty(lvls)
    lvls = [0.5 1.5 2.5 3.5];
%end

if ~isempty(vAng)
    if strcmpi(vAng,'l')
        vAng2(1) = 180;
        vAng2(2) = -100;
    elseif strcmpi(vAng,'ud')
        vAng2(1) = 90;
        vAng2(2) = -90;
    end
else 
    vAng2 = [];
end

if iscell(inFU)
    l = length(inFU);
else
    l = 1;
    inFU={inFU};
end
 
for i = 1:l
    tmp.vol(:,:,:,i) = double(niftiread(inFU{i}));
end

tmp2.vol = double(niftiread(inFO));
if maskOF
    idx = unique(find(tmp.vol == 0));
    tmp2.vol(idx) = 0;
end

if isempty(uCmpNm)
    if contr
        if l == 1
            uCmpNm = 'gray';
        else
            uCmpNm = jet(l);
        end
    else
        uCmpNm = 'gray';
    end
else
    if contr
        if l > 1
            [uCmpNm,~,~,~,~] = colormapper([1:l],'colorBins',l,'colormap',uCmpNm);
        else
            uCmpNm = [0 0 0];
        end
    else
        uCmpNm = 'gray';
    end
end

% if isempty(contClr)
%     if l == 1
%         contClr = [0 0 0];
%     else
%         contClr = jet(l);
%     end
% else
%     [contClr,~,~,~,~] = colormapper([1:l],'colorBins',l,'colormap',contClr);
% end

if ~isempty(uLim)
    ulins = linspace(min(uLim),max(uLim),uBin);
else
    if isempty(find(tmp.vol < 0))
        ulins=linspace(min(tmp.vol(:)),max(tmp.vol(:)),uBin);
    else
        ulins=linspace(-1*max(abs([min(tmp.vol(:)) max(tmp.vol(:))])),max(abs([min(tmp.vol(:)) max(tmp.vol(:))])),uBin);
        
        if ~useRawLims
            ulins=linspace(-1*max(abs([min(tmp.vol(:)) max(tmp.vol(:))])),max(abs([min(tmp.vol(:)) max(tmp.vol(:))])),uBin);
        else
            ulins=linspace(min(tmp.vol(:)),max(tmp.vol(:)),uBin);
        end
    end
end

if ~isempty(oLim)
    olins = linspace(min(oLim),max(oLim),oBin);
else
    if isempty(find(tmp2.vol < 0))
        olins=linspace(min(tmp2.vol(:)),max(tmp2.vol(:)),oBin);
    else
        if ~useRawLims
            olins=linspace(-1*max(abs([min(tmp2.vol(:)) max(tmp2.vol(:))])),max(abs([min(tmp2.vol(:)) max(tmp2.vol(:))])),oBin);
        else
            olins=linspace(min(tmp2.vol(:)),max(tmp2.vol(:)),oBin);
        end
    end
end
if isempty(sls)
    sls = 1:size(tmp.vol,3);
end
 
figure;
hold on
if contr
    v1 = round(length(sls)/5);
    v2 = ceil(length(sls)/v1);
    t = tiledlayout(v1,v2,'TileSpacing','tight','Padding','compact');
    for i = 1:length(sls)
        nexttile
        m = [min(tmp2.vol(:,:,sls(i))) max(tmp2.vol(:,:,sls(i)))];
        im{i} = imshow(tmp2.vol(:,:,sls(i)),[min(m) max(m)]);
        [cMap,cData,cbData,ticks,tickLabels] = colormapper(im{i}.CData(:),'colorBins',oBin,'colormap',oCmpNm,'limits',[olins(1) olins(end)],'thresh',oThr);
        [a, b, uIdx] = unique(cData,'rows');
        modeIdx = mode(uIdx);
        modeRow = a(modeIdx,:);
        idx = find(ismember(cData, modeRow, 'rows'));
        cData(idx,1) = backClr(1);
        cData(idx,2) = backClr(3);
        cData(idx,3) = backClr(3);
        cDatar = reshape(cData,[size(im{i}.CData,1),size(im{i}.CData,2),3]);
        im{i}.CData = cDatar;
        for j = 1:l
            hold on
            [~,cont{i,j}] = imcontour(tmp.vol(:,:,sls(i),j));
            cont{i,j}.LevelList = lvls;
            cont{i,j}.LineWidth = 4;
            cont{i,j}.LineColor = uCmpNm(j,:);%[0 0 0];
            if ~isempty(vAng2)
                view(vAng2)
            end
        end
    end
else
    m1 = montage(tmp.vol,'DisplayRange',[min(ulins) max(ulins)],'Indices',sls);
    [cMap,cData,cbData,ticks,tickLabels] = colormapper(m1.CData(:),'colorBins',uBin,'colormap',uCmpNm,'limits',[ulins(1) ulins(end)],'thresh',uThr);
    [a, b, uIdx] = unique(cData,'rows');
    modeIdx = mode(uIdx);
    modeRow = a(modeIdx,:);
    idx = find(ismember(cData, modeRow, 'rows'));
    cData(idx,1) = backClr(1);
    cData(idx,2) = backClr(3);
    cData(idx,3) = backClr(3);
    cDatar = reshape(cData,[size(m1.CData,1),size(m1.CData,2),3]);
    m1.CData = cDatar;
    hold on

    m2 = montage(tmp2.vol,'DisplayRange',[olins(1) olins(end)],'Indices',sls);
    [cMap,cData,cbData,ticks,~] = colormapper(m2.CData(:),'colorBins',oBin,'colormap',oCmpNm,'limits',[olins(1) olins(end)],'thresh',oThr);
    [a, b, uIdx] = unique(cData,'rows');
    modeIdx = mode(uIdx);
    modeRow = a(modeIdx,:);
    idx = find(ismember(cData, modeRow, 'rows'));
    cData(idx,1) = backClr(1);
    cData(idx,2) = backClr(3);
    cData(idx,3) = backClr(3);
    cDatar = reshape(cData,[size(m1.CData,1),size(m1.CData,2),3]);
    m2.CData = cDatar; %m1.CDataMapping ='direct';
    m2.AlphaData = oAlpha;
    if ~isempty(vAng2)
        view(vAng2)
    end
end
set(gcf,'color','w');

