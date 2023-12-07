#!/bin/bash

# modelscope下载链接格式
# https://modelscope.cn/api/v1/models/作者/仓库/repo?Revision=分支名&FilePath=文件名
# https://modelscope.cn/api/v1/models/作者/仓库/repo?Revision=分支名&FilePath=文件夹/文件名

# modelscope模型下载
# 使用格式:
# get_modelscope_model 作者/仓库/仓库分支/仓库文件路径/文件名 本地下载路径
# get_modelscope_model 作者/仓库/仓库分支/文件名 本地下载路径
# 例:
# get_modelscope_model licyks/sd-model/master/sd_1.5/v1-5-pruned-emaonly.safetensors ./stable-diffusion-webui/models/Stable-diffusion
# get_modelscope_model licyks/controlnet_v1.1/master/t2iadapter_zoedepth_sd15v1.pth ./stable-diffusion-webui/

get_modelscope_model()
{
    local modelscope_user=$(echo $@ | awk '{gsub(/[/]/, " ")}1' | awk '{print$1}')
    local modelscope_name=$(echo $@ | awk '{gsub(/[/]/, " ")}1' | awk '{print$2}')
    local modelscope_branch=$(echo $@ | awk '{gsub(/[/]/, " ")}1' | awk '{print$3}')
    local modelscope_model_path=$(echo $1 | awk '{sub("'${modelscope_user}/${modelscope_name}/${modelscope_branch}/'","")}1')
    local modelscope_model_url="https://modelscope.cn/api/v1/models/${modelscope_user}/${modelscope_name}/repo?Revision=${modelscope_branch}&FilePath=${modelscope_model_path}"

    if [ ! -z "$3" ];then
        local local_file_path="${2}/${3}"
        local local_aria_cache_path="${2}/${3}.aria2"

    else
        local local_file_path="${2}/$(echo $1 | awk -F'/' '{print$NF}')"
        local local_aria_cache_path="${2}/$(echo $1 | awk -F'/' '{print$NF}').aria2"
    fi

    if [ ! -f "$local_file_path" ];then
        term_sd_echo "下载$(echo $modelscope_model_path | awk -F '/' '{print$NF}')中"
        term_sd_watch aria2c $aria2_multi_threaded $modelscope_model_url -d ${2} -o $(echo $local_file_path | awk -F'/' '{print$NF}')
    else
        if [ -f "$local_aria_cache_path" ];then
            term_sd_echo "恢复下载$(echo $modelscope_model_path | awk -F '/' '{print$NF}')中"
            term_sd_watch aria2c $aria2_multi_threaded $modelscope_model_url -d ${2} -o $(echo $local_file_path | awk -F'/' '{print$NF}')
        else
            term_sd_echo "$(echo $modelscope_model_path | awk -F '/' '{print$NF}')文件已存在,跳过下载该文件"
        fi
    fi
}

