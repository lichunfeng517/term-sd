#!/bin/bash

# fooocus启动脚本生成部分
fooocus_launch_args_setting()
{
    local fooocus_launch_args
    local fooocus_launch_args_setting_dialog

    fooocus_launch_args_setting_dialog=$(
        dialog --erase-on-exit --notags --title "Fooocus管理" --backtitle "Fooocus启动参数选项" --ok-label "确认" --cancel-label "取消" --checklist "请选择Fooocus启动参数,确认之后将覆盖原有启动参数配置" $term_sd_dialog_height $term_sd_dialog_width $term_sd_dialog_menu_height \
        "1" "(listen)开放远程连接" OFF \
        "2" "(disable-header-check)" ON \
        "3" "(in-browser)启动后自动打开浏览器" OFF \
        "4" "(disable-in-browser)禁用自动打开浏览器" OFF\
        "5" "(async-cuda-allocation)启用CUDA流顺序内存分配器" OFF \
        "6" "(disable-async-cuda-allocation)禁用CUDA流顺序内存分配器" OFF \
        "7" "(disable-attention-upcast)使用向上采样法提高精度" OFF \
        "8" "(all-in-fp32)强制使用fp132" OFF \
        "9" "(all-in-fp16)强制使用fp132" OFF \
        "10" "(unet-in-bf16)使用bf16精度运行unet" OFF \
        "11" "(unet-in-fp16)使用fp16精度运行unet" OFF \
        "12" "(unet-in-fp8-e4m3fn)使用fp8(e4m3fn)精度运行unet" OFF \
        "13" "(unet-in-fp8-e5m2)使用fp8(e5m2)精度运行unet" OFF \
        "14" "(vae-in-fp16)使用fp16精度运行vae" OFF \
        "15" "(vae-in-fp32)使用fp32精度运行vae" OFF \
        "16" "(vae-in-bf16)使用bf16精度运行vae" OFF \
        "17" "(clip-in-fp8-e4m3fn)使用fp8(e4m3fn)精度运行clip" OFF \
        "18" "(clip-in-fp8-e5m2)使用fp8(e5m2)精度运行clip" OFF \
        "19" "(clip-in-fp16)使用fp16精度运行clip" OFF \
        "20" "(clip-in-fp32)使用fp32精度运行clip" OFF \
        "21" "(directml)使用directml作为后端" OFF \
        "22" "(disable-ipex-hijack)禁用ipex修复" OFF \
        "23" "(attention-split)使用split优化" OFF \
        "24" "(attention-quad)使用quad优化" OFF \
        "25" "(attention-pytorch)使用PyTorch方案优化" OFF \
        "26" "(disable-xformers)禁用xformers优化" OFF \
        "27" "(always-gpu)将所有模型,文本编码器储存在GPU中" OFF \
        "28" "(always-high-vram)不使用显存优化" OFF \
        "29" "(always-normal-vram)使用默认显存优化" OFF \
        "30" "(always-low-vram)使用显存优化(将会降低生图速度)" OFF \
        "31" "(always-no-vram)使用显存优化(将会大量降低生图速度)" OFF \
        "32" "(always-cpu)使用CPU进行生图" OFF \
        "33" "(always-offload-from-vram)保持模型储存在显存中而不是自动卸载到内存中" OFF \
        "34" "(pytorch-deterministic)将PyTorch配置为使用确定性算法" OFF \
        "34" "(disable-server-log)禁用服务端日志输出" OFF \
        "34" "(debug-mode)启用debug模式" OFF \
        "34" "(is-windows-embedded-python)启用Windows独占功能" OFF \
        "34" "(disable-server-info)禁用服务端信息输出" OFF \
        "34" "(language zh)启用中文" OFF \
        "34" "(theme dark)使用黑暗主题" OFF \
        "34" "(disable-image-log)禁用将图像和日志写入硬盘" OFF \
        "34" "(disable-analytics)禁用gradio分析" OFF \
        3>&1 1>&2 2>&3)

    if [ $? = 0 ];then
        for i in $fooocus_launch_args_setting_dialog; do
            case $i in
                1)
                    fooocus_launch_args="--listen $fooocus_launch_args"
                    ;;
                2)
                    fooocus_launch_args="--disable-header-check $fooocus_launch_args"
                    ;;
                3)
                    fooocus_launch_args="--in-browser $fooocus_launch_args"
                    ;;
                4)
                    fooocus_launch_args="--disable-in-browser $fooocus_launch_args"
                    ;;
                5)
                    fooocus_launch_args="--async-cuda-allocation $fooocus_launch_args"
                    ;;
                6)
                    fooocus_launch_args="--disable-async-cuda-allocation $fooocus_launch_args"
                    ;;
                7)
                    fooocus_launch_args="--disable-attention-upcast $fooocus_launch_args"
                    ;;
                8)
                    fooocus_launch_args="--all-in-fp32 $fooocus_launch_args"
                    ;;
                9)
                    fooocus_launch_args="--all-in-fp16 $fooocus_launch_args"
                    ;;
                10)
                    fooocus_launch_args="--unet-in-bf16 $fooocus_launch_args"
                    ;;
                11)
                    fooocus_launch_args="--unet-in-fp16 $fooocus_launch_args"
                    ;;
                12)
                    fooocus_launch_args="--unet-in-fp8-e4m3fn $fooocus_launch_args"
                    ;;
                13)
                    fooocus_launch_args="--unet-in-fp8-e5m2 $fooocus_launch_args"
                    ;;
                14)
                    fooocus_launch_args="--vae-in-fp16 $fooocus_launch_args"
                    ;;
                15)
                    fooocus_launch_args="--vae-in-fp32 $fooocus_launch_args"
                    ;;
                16)
                    fooocus_launch_args="--vae-in-bf16 $fooocus_launch_args"
                    ;;
                17)
                    fooocus_launch_args="--clip-in-fp8-e4m3fn $fooocus_launch_args"
                    ;;
                18)
                    fooocus_launch_args="--clip-in-fp8-e5m2 $fooocus_launch_args"
                    ;;
                19)
                    fooocus_launch_args="--clip-in-fp16 $fooocus_launch_args"
                    ;;
                20)
                    fooocus_launch_args="--clip-in-fp32 $fooocus_launch_args"
                    ;;
                21)
                    fooocus_launch_args="--directml $fooocus_launch_args"
                    ;;
                22)
                    fooocus_launch_args="--disable-ipex-hijack $fooocus_launch_args"
                    ;;
                23)
                    fooocus_launch_args="--attention-split $fooocus_launch_args"
                    ;;
                24)
                    fooocus_launch_args="--attention-quad $fooocus_launch_args"
                    ;;
                25)
                    fooocus_launch_args="--attention-pytorch $fooocus_launch_args"
                    ;;
                26)
                    fooocus_launch_args="--disable-xformers $fooocus_launch_args"
                    ;;
                27)
                    fooocus_launch_args="--always-gpu $fooocus_launch_args"
                    ;;
                28)
                    fooocus_launch_args="--always-high-vram $fooocus_launch_args"
                    ;;
                29)
                    fooocus_launch_args="--always-normal-vram $fooocus_launch_args"
                    ;;
                30)
                    fooocus_launch_args="--always-low-vram $fooocus_launch_args"
                    ;;
                31)
                    fooocus_launch_args="--always-no-vram $fooocus_launch_args"
                    ;;
                32)
                    fooocus_launch_args="--always-cpu $fooocus_launch_args"
                    ;;
                33)
                    fooocus_launch_args="--always-offload-from-vram $fooocus_launch_args"
                    ;;
                34)
                    fooocus_launch_args="--pytorch-deterministic $fooocus_launch_args"
                    ;;
                35)
                    fooocus_launch_args="--disable-server-log $fooocus_launch_args"
                    ;;
                36)
                    fooocus_launch_args="--debug-mode $fooocus_launch_args"
                    ;;
                37)
                    fooocus_launch_args="--is-windows-embedded-python $fooocus_launch_args"
                    ;;
                38)
                    fooocus_launch_args="--disable-server-info $fooocus_launch_args"
                    ;;
                39)
                    fooocus_launch_args="--language zh $fooocus_launch_args"
                    ;;
                40)
                    fooocus_launch_args="--theme dark $fooocus_launch_args"
                    ;;
                41)
                    fooocus_launch_args="--disable-image-log $fooocus_launch_args"
                    ;;
                42)
                    fooocus_launch_args="--disable-analytics $fooocus_launch_args"
                    ;;
                
            esac
        done

        term_sd_echo "设置启动参数:  $fooocus_launch_args"
        echo "launch.py $fooocus_launch_args" > "$start_path"/term-sd/config/fooocus-launch.conf
    fi
}

# fooocus启动界面
fooocus_launch()
{
    local fooocus_launch_dialog

    if [ ! -f "$start_path/term-sd/config/fooocus-launch.conf" ]; then # 找不到启动配置时默认生成一个
        term_sd_echo "未找到启动配置文件,创建中"
        echo "launch.py --language zh" > "$start_path"/term-sd/config/fooocus-launch.conf
    fi

    fooocus_launch_dialog=$(
        dialog --erase-on-exit --notags --title "Fooocus管理" --backtitle "Fooocus启动选项" --ok-label "确认" --cancel-label "取消" --menu "请选择启动Fooocus/修改Fooocus启动参数\n当前启动参数:\n$([ $venv_setup_status = 0 ] && echo python || echo "$term_sd_python_path") $(cat "$start_path"/term-sd/config/fooocus-launch.conf)" $term_sd_dialog_height $term_sd_dialog_width $term_sd_dialog_menu_height \
        "0" "> 返回" \
        "1" "> 启动" \
        "2" "> 配置预设启动参数" \
        "3" "> 修改自定义启动参数" \
        3>&1 1>&2 2>&3)

    case $fooocus_launch_dialog in
        1)
            term_sd_launch
            fooocus_launch
            ;;
        2)
            fooocus_launch_args_setting
            fooocus_launch
            ;;
        3)
            fooocus_manual_launch
            fooocus_launch
            ;;
    esac
}

# fooocus手动输入启动参数界面
fooocus_manual_launch()
{
    local fooocus_launch_args

    fooocus_launch_args=$(dialog --erase-on-exit --title "Fooocus管理" --backtitle "Fooocus自定义启动参数选项" --ok-label "确认" --cancel-label "取消" --inputbox "请输入Fooocus启动参数" $term_sd_dialog_height $term_sd_dialog_width "$(cat "$start_path"/term-sd/config/fooocus-launch.conf | awk '{sub("launch.py ","")}1')" 3>&1 1>&2 2>&3)

    if [ $? = 0 ];then
        term_sd_echo "设置启动参数:  $fooocus_launch_args"
        echo "launch.py $fooocus_launch_args" > "$start_path"/term-sd/config/fooocus-launch.conf
    fi
}