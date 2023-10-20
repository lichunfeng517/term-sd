#!/bin/bash

#comfyui选项
function comfyui_option()
{
    export term_sd_manager_info="ComfyUI"
    cd "$start_path" #回到最初路径
    exit_venv #确保进行下一步操作前已退出其他虚拟环境
    if [ -d "ComfyUI" ];then
        cd ComfyUI
        comfyui_option_dialog=$(
            dialog --clear --title "ComfyUI管理" --backtitle "ComfyUI管理选项" --ok-label "确认" --cancel-label "取消" --menu "请选择ComfyUI管理选项的功能\n当前更新源:$(git remote -v | awk 'NR==1 {print $2}')" 25 70 10 \
            "1" "更新" \
            "2" "卸载" \
            "3" "修复更新" \
            "4" "自定义节点管理" \
            "5" "插件管理" \
            "6" "切换版本" \
            "7" "更新源切换" \
            "8" "启动" \
            "9" "更新依赖" \
            "10" "重新安装" \
            "11" "重新安装pytorch" \
            "12" "python软件包安装/重装/卸载" \
            "13" "依赖库版本管理" \
            $dialog_recreate_venv_button \
            $dialog_rebuild_venv_button \
            "20" "返回" \
            3>&1 1>&2 2>&3)

        if [ $? = 0 ];then
            if [ $comfyui_option_dialog = 1 ]; then
                term_sd_notice "更新ComfyUI中"
                git pull
                if [ $? = 0 ];then
                    dialog --clear --title "ComfyUI管理" --backtitle "ComfyUI更新结果" --ok-label "确认" --msgbox "ComfyUI更新成功" 25 70
                else
                    dialog --clear --title "ComfyUI管理" --backtitle "ComfyUI更新结果" --ok-label "确认" --msgbox "ComfyUI更新失败" 25 70
                fi
                comfyui_option
            elif [ $comfyui_option_dialog = 2 ]; then
                if (dialog --clear --title "ComfyUI管理" --backtitle "ComfyUI删除选项" --yes-label "是" --no-label "否" --yesno "是否删除ComfyUI?" 25 70) then
                    term_sd_notice "删除ComfyUI中"
                    exit_venv
                    cd ..
                    rm -rf ./ComfyUI
                else
                    comfyui_option
                fi
            elif [ $comfyui_option_dialog = 3 ]; then
                term_sd_fix_pointer_offset
                comfyui_option
            elif [ $comfyui_option_dialog = 4 ]; then
                export comfyui_extension_info=1 #1代表自定义节点，其他数字代表插件
                cd custom_nodes
                comfyui_custom_node_methon
                comfyui_option
            elif [ $comfyui_option_dialog = 5 ]; then
                export comfyui_extension_info=2
                cd web/extensions
                comfyui_extension_methon
                comfyui_option
            elif [ $comfyui_option_dialog = 6 ]; then
                git_checkout_manager
                comfyui_option
            elif [ $comfyui_option_dialog = 7 ]; then
                comfyui_change_repo
                comfyui_option
            elif [ $comfyui_option_dialog = 8 ]; then
                if [ ! -f "./term-sd-launch.conf" ]; then #找不到启动配置时默认生成一个
                    term_sd_notice "未找到启动配置文件,创建中"
                    echo "main.py " > term-sd-launch.conf
                fi
                comfyui_launch
                comfyui_option
            elif [ $comfyui_option_dialog = 9 ]; then
                comfyui_update_depend
                comfyui_option
            elif [ $comfyui_option_dialog = 10 ]; then
                if (dialog --clear --title "ComfyUI管理" --backtitle "ComfyUI重新安装选项" --yes-label "是" --no-label "否" --yesno "是否重新安装ComfyUI?" 25 70) then
                    cd "$start_path"
                    exit_venv
                    process_install_comfyui
                else
                    comfyui_option
                fi
            elif [ $comfyui_option_dialog = 11 ]; then
                pytorch_reinstall
                comfyui_option
            elif [ $comfyui_option_dialog = 12 ]; then
                manage_python_packages
                comfyui_option
            elif [ $comfyui_option_dialog = 13 ]; then
                python_package_ver_backup_or_restore
                comfyui_option
            elif [ $comfyui_option_dialog = 18 ]; then
                if (dialog --clear --title "ComfyUI管理" --backtitle "ComfyUI虚拟环境修复选项" --yes-label "是" --no-label "否" --yesno "是否修复ComfyUI的虚拟环境" 25 70);then
                    create_venv --fix
                fi
                comfyui_option
            elif [ $comfyui_option_dialog = 19 ]; then
                if (dialog --clear --title "ComfyUI管理" --backtitle "ComfyUI虚拟环境重建选项" --yes-label "是" --no-label "否" --yesno "是否重建ComfyUI的虚拟环境" 25 70);then
                    comfyui_venv_rebuild
                fi
                comfyui_option
            fi
        fi
    else
        if (dialog --clear --title "ComfyUI管理" --backtitle "ComfyUI安装选项" --yes-label "是" --no-label "否" --yesno "检测到当前未安装ComfyUI,是否进行安装?" 25 70) then
            process_install_comfyui
        fi
    fi
}

#comfyui依赖更新功能
function comfyui_update_depend()
{
    if (dialog --clear --title "ComfyUI管理" --backtitle "ComfyUI依赖更新选项" --yes-label "是" --no-label "否" --yesno "是否更新ComfyUI的依赖?" 25 70);then
        #更新前的准备
        proxy_option #代理选择
        pip_install_methon #安装方式选择
        final_install_check #安装前确认

        if [ $final_install_check_exec = 0 ];then
            print_line_to_shell "ComfyUI依赖更新"
            term_sd_notice "更新ComfyUI依赖中"
            tmp_disable_proxy
            create_venv
            enter_venv
            requirements_python_package_update "./requirements.txt"
            exit_venv
            tmp_enable_proxy
            term_sd_notice "更新ComfyUI依赖结束"
            print_line_to_shell
        fi
    fi
}
