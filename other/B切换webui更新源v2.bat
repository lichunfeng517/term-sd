@echo off

set orig=https://github.com/AUTOMATIC1111/stable-diffusion-webui
echo ��ѡ�����Դ��
echo 1.githubԴ 2.����Դ
set /p choice=�������ֺ󰴻س���

if %choice% == 2 (
	echo ��������ԴΪ jihulab/hunter0725
	.\git\bin\git.exe remote set-url origin "https://jihulab.com/hunter0725/stable-diffusion-webui.git"
	.\git\bin\git.exe -C "repositories\k-diffusion" remote set-url origin "https://jihulab.com/hunter0725/k-diffusion.git"
	.\git\bin\git.exe -C "repositories\BLIP" remote set-url origin "https://jihulab.com/hunter0725/BLIP.git"
	.\git\bin\git.exe -C "repositories\CodeFormer" remote set-url origin "https://jihulab.com/hunter0725/CodeFormer.git"
	.\git\bin\git.exe -C "repositories\stable-diffusion" remote set-url origin "https://jihulab.com/hunter0725/stable-diffusion.git"
	.\git\bin\git.exe -C "repositories\taming-transformers" remote set-url origin "https://jihulab.com/hunter0725/taming-transformers.git"
) else (
	echo ��������ԴΪ githubԴ
	.\git\bin\git.exe remote set-url origin %orig%
	.\git\bin\git.exe -C "repositories\k-diffusion" remote set-url origin "https://github.com/crowsonkb/k-diffusion.git"
	.\git\bin\git.exe -C "repositories\BLIP" remote set-url origin "https://github.com/salesforce/BLIP.git"
	.\git\bin\git.exe -C "repositories\CodeFormer" remote set-url origin "https://github.com/sczhou/CodeFormer.git"
	.\git\bin\git.exe -C "repositories\stable-diffusion" remote set-url origin "https://github.com/CompVis/stable-diffusion.git"
	.\git\bin\git.exe -C "repositories\taming-transformers" remote set-url origin "https://github.com/CompVis/taming-transformers.git"
)

pause