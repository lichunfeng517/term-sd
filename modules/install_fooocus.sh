#!/bin/bash

# Fooocus安装
install_fooocus()
{
    local cmd_sum
    local cmd_point

    if [ -f "$start_path/term-sd/task/fooocus_install.sh" ];then # 检测到有未完成的安装任务时直接执行安装任务
        cmd_sum=$(( $(cat "$start_path/term-sd/task/fooocus_install.sh" | wc -l) + 1 )) # 统计命令行数
        term_sd_print_line "Fooocus 安装"
        for ((cmd_point=1; cmd_point <= cmd_sum; cmd_point++))
        do
            term_sd_echo "Fooocus 安装进度: [$cmd_point/$cmd_sum]"

            term_sd_exec_cmd "$start_path/term-sd/task/fooocus_install.sh" $cmd_point

            if [ ! $? = 0 ];then
                if [ $term_sd_install_mode = 0 ];then
                    term_sd_echo "安装命令执行失败, 终止安装程序"
                    term_sd_tmp_enable_proxy # 恢复代理
                    term_sd_pause

                    dialog --erase-on-exit \
                        --title "Fooocus 管理" \
                        --backtitle "Fooocus 安装结果" \
                        --ok-label "确认" \
                        --msgbox "Fooocus 安装进程执行失败, 请重试" \
                        $term_sd_dialog_height $term_sd_dialog_width

                    return 1
                else
                    term_sd_echo "忽略执行失败的命令"
                fi
            fi
        done

        term_sd_tmp_enable_proxy # 恢复代理
        term_sd_echo "Fooocus 安装结束"
        rm -f "$start_path/term-sd/task/fooocus_install.sh" # 删除任务文件
        term_sd_print_line

        dialog --erase-on-exit \
            --title "Fooocus 管理" \
            --backtitle "Fooocus 安装结果" \
            --ok-label "确认" \
            --msgbox "Fooocus 安装结束, 选择确定进入管理界面" \
            $term_sd_dialog_height $term_sd_dialog_width

        fooocus_manager # 进入管理界面
    else # 生成安装任务并执行安装任务
        # 安装前的准备
        download_mirror_select auto_github_mirrror # 下载镜像源选择
        pytorch_version_select # pytorch版本选择
        fooocus_download_model_select # 模型选择
        pip_install_mode_select # 安装方式选择
        term_sd_install_confirm "是否安装 Fooocus ?" # 安装确认
        if [ $? = 0 ];then
            term_sd_print_line "Fooocus 安装"
            term_sd_echo "生成安装任务中"
            term_sd_set_install_env_value >> "$start_path/term-sd/task/fooocus_install.sh" # 环境变量
            cat "$start_path/term-sd/install/fooocus/fooocus_core.sh" >> "$start_path/term-sd/task/fooocus_install.sh" # 核心组件
            term_sd_add_blank_line "$start_path/term-sd/task/fooocus_install.sh"

            # 模型下载
            if [ $use_modelscope_model = 1 ];then
                # 恢复代理
                echo "__term_sd_task_sys term_sd_tmp_enable_proxy" >> "$start_path/term-sd/task/fooocus_install.sh"
                # 读取模型
                for i in $fooocus_download_model_select_list ;do
                    cat "$start_path/term-sd/install/fooocus/fooocus_hf_model.sh" | grep -w $i >> "$start_path/term-sd/task/fooocus_install.sh" # 插件所需的模型
                done
            else
                for i in $fooocus_download_model_select_list ;do
                    cat "$start_path/term-sd/install/fooocus/fooocus_ms_model.sh" | grep -w $i >> "$start_path/term-sd/task/fooocus_install.sh" # 插件所需的模型
                done
            fi

            term_sd_echo "任务队列生成完成"
            term_sd_echo "开始安装 Fooocus"

            # 执行安装命令
            cmd_sum=$(( $(cat "$start_path/term-sd/task/fooocus_install.sh" | wc -l) + 1 )) # 统计命令行数
            for ((cmd_point=1; cmd_point <= cmd_sum; cmd_point++))
            do
                term_sd_echo "Fooocus 安装进度: [$cmd_point/$cmd_sum]"

                term_sd_exec_cmd "$start_path/term-sd/task/fooocus_install.sh" $cmd_point

                if [ ! $? = 0 ];then
                    if [ $term_sd_install_mode = 0 ];then
                        term_sd_echo "安装命令执行失败, 终止安装程序"
                        term_sd_tmp_enable_proxy # 恢复代理
                        term_sd_pause

                        dialog --erase-on-exit \
                            --title "Fooocus 管理" \
                            --backtitle "Fooocus 安装结果" \
                            --ok-label "确认" \
                            --msgbox "Fooocus 安装进程执行失败, 请重试" \
                            $term_sd_dialog_height $term_sd_dialog_width

                        return 1
                    else
                        term_sd_echo "忽略执行失败的命令"
                    fi
                fi
            done

            term_sd_tmp_enable_proxy # 恢复代理
            term_sd_echo "Fooocus 安装结束"
            rm -f "$start_path/term-sd/task/fooocus_install.sh" # 删除任务文件
            term_sd_print_line

            dialog --erase-on-exit \
                --title "Fooocus 管理" \
                --backtitle "Fooocus 安装结果" \
                --ok-label "确认" \
                --msgbox "Fooocus 安装结束, 选择确定进入管理界面" \
                $term_sd_dialog_height $term_sd_dialog_width

            fooocus_manager # 进入管理界面
        fi
    fi
}

# 模型选择
fooocus_download_model_select()
{
    local fooocus_custom_node_model_list
    local fooocus_model_list_file

    term_sd_echo "生成模型选择列表中"
    if [ $use_modelscope_model = 0 ];then
        fooocus_model_list_file="dialog_fooocus_ms_model.sh"
    else
        fooocus_model_list_file="dialog_fooocus_hf_model.sh"
    fi

    # 模型选择
    fooocus_download_model_select_list=$(dialog --erase-on-exit --notags \
        --title "Fooocus 安装" \
        --backtitle "Fooocus 模型下载选项" \
        --ok-label "确认" --no-cancel \
        --checklist "请选择需要下载的 Fooocus 模型" \
        $term_sd_dialog_height $term_sd_dialog_width $term_sd_dialog_menu_height \
        "_null_" "=====基础模型选择=====" ON \
        $(cat "$start_path/term-sd/install/fooocus/$fooocus_model_list_file") \
        3>&1 1>&2 2>&3)
}

# fooocus预设文件
fooocus_preset_file()
{
    cat<<EOF
{
    "default_model": "animagine-xl-3.1.safetensors",
    "default_refiner": "None",
    "default_refiner_switch": 0.8,
    "default_loras": [
        [
            "sd_xl_offset_example-lora_1.0.safetensors",
            0.5
        ],
        [
            "None",
            1.0
        ],
        [
            "None",
            1.0
        ],
        [
            "None",
            1.0
        ],
        [
            "None",
            1.0
        ]
    ],
    "default_cfg_scale": 5.0,
    "default_sample_sharpness": 2.0,
    "default_sampler": "dpmpp_2m_sde_gpu",
    "default_scheduler": "sgm_uniform",
    "default_performance": "Speed",
    "default_prompt": "",
    "default_prompt_negative": "low quality,worst quality,normal quality,text,signature,jpeg artifacts,bad anatomy,old,early,copyright name,watermark,artist name,signature,",
    "default_styles": [
    ],
    "default_image_number": 1,
    "default_aspect_ratio": "1344*1008",
    "checkpoint_downloads": {},
    "embeddings_downloads": {},
    "lora_downloads": {},
    "available_aspect_ratios": [
        "704*1408",
        "704*1344",
        "768*1344",
        "768*1280",
        "832*1216",
        "1216*832",
        "832*1152",
        "896*1152",
        "896*1088",
        "960*1088",
        "960*1024",
        "1024*1024",
        "1024*960",
        "1088*960",
        "1088*896",
        "1152*896",
        "1152*832",
        "1216*832",
        "1280*768",
        "1344*768",
        "1344*704",
        "1408*704",
        "1472*704",
        "1536*640",
        "1600*640",
        "1664*576",
        "1728*576",
        "1920*1080",
        "1080*1920",
        "576*1024",
        "768*1024",
        "1024*576",
        "1024*768",
        "1024*1024",
        "2048*2048",
        "1536*864",
        "864*1536",
        "1472*828",
        "828*1472",
        "1344*756",
        "756*1344",
        "1344*1008",
        "1008*1344",
        "1536*1152",
        "1152*1536",
        "1472*1104",
        "1104*1472",
        "1920*640",
        "1920*824",
        "824*1920",
        "1920*768",
        "1536*768",
        "1488*640",
        "1680*720"
    ],
    "default_save_metadata_to_images": true,
    "default_metadata_scheme": "a1111",
    "default_clip_skip": 2,
    "default_black_out_nsfw": false,
    "metadata_created_by": "Fooocus"
}
EOF
}

# fooocus翻译配置文件
fooocus_lang_config_file()
{
    cat<<EOF
{
    "Preview": "预览",
    "Gallery": "相册",
    "Generate": "生成",
    "Skip": "跳过",
    "Stop": "停止",
    "Input Image": "图生图",
    "Advanced": "高级设置",
    "Upscale or Variation": "放大或重绘",
    "Image Prompt": "参考图",
    "Inpaint or Outpaint (beta)": "内部重绘或外部扩展（测试版）",
    "Drag above image to here": "将图像拖到这里",
    "Upscale or Variation:": "放大或重绘：",
    "Disabled": "禁用",
    "Vary (Subtle)": "变化（微妙）",
    "Vary (Strong)": "变化（强烈）",
    "Upscale (1.5x)": "放大（1.5 倍）",
    "Upscale (2x)": "放大（2 倍）",
    "Upscale (Fast 2x)": "快速放大（2 倍）",
    "\ud83d\udcd4 Document": "\uD83D\uDCD4 说明文档",
    "Image": "图像",
    "Stop At": "停止于",
    "Weight": "权重",
    "Type": "类型",
    "PyraCanny": "边缘检测",
    "CPDS": "深度结构检测",
    "* \"Image Prompt\" is powered by Fooocus Image Mixture Engine (v1.0.1).": "* “图生图”由 Fooocus 图像混合引擎提供支持（v1.0.1）。",
    "The scaler multiplied to positive ADM (use 1.0 to disable).": "正向 ADM 的缩放倍数（使用 1.0 禁用）。",
    "The scaler multiplied to negative ADM (use 1.0 to disable).": "反向 ADM 的缩放倍数（使用 1.0 禁用）。",
    "When to end the guidance from positive/negative ADM.": "何时结束来自正向 / 反向 ADM 的指导。",
    "Similar to the Control Mode in A1111 (use 0.0 to disable).": "类似于 SD WebUI 中的控制模式（使用 0.0 禁用）。",
    "Outpaint Expansion (": "外部扩展 (",
    "Outpaint": "外部重绘",
    "Left": "向左扩展",
    "Right": "向右扩展",
    "Top": "向上扩展",
    "Bottom": "向下扩展",
    "* \"Inpaint or Outpaint\" is powered by the sampler \"DPMPP Fooocus Seamless 2M SDE Karras Inpaint Sampler\" (beta)": "* “内部填充或外部填充”由“DPMPP Fooocus Seamless 2M SDE Karras Inpaint Sampler”（测试版）采样器提供支持",
    "Setting": "设置",
    "Style": "样式",
    "Performance": "性能",
    "Speed": "均衡",
    "Quality": "质量",
    "Extreme Speed": "LCM 加速",
    "Lightning": "SDXL Lightning 加速",
    "Hyper-SD": "Hyper SD 加速",
    "Aspect Ratios": "宽高比",
    "896\u00d71152": "896\u00d71152",
    "width \u00d7 height": "宽 \u00d7 高",
    "704\u00d71408": "704\u00d71408",
    "704\u00d71344": "704\u00d71344",
    "768\u00d71344": "768\u00d71344",
    "768\u00d71280": "768\u00d71280",
    "832\u00d71216": "832\u00d71216",
    "832\u00d71152": "832\u00d71152",
    "896\u00d71088": "896\u00d71088",
    "960\u00d71088": "960\u00d71088",
    "960\u00d71024": "960\u00d71024",
    "1024\u00d71024": "1024\u00d71024",
    "1024\u00d7960": "1024\u00d7960",
    "1088\u00d7960": "1088\u00d7960",
    "1088\u00d7896": "1088\u00d7896",
    "1152\u00d7832": "1152\u00d7832",
    "1216\u00d7832": "1216\u00d7832",
    "1280\u00d7768": "1280\u00d7768",
    "1344\u00d7768": "1344\u00d7768",
    "1344\u00d7704": "1344\u00d7704",
    "1408\u00d7704": "1408\u00d7704",
    "1472\u00d7704": "1472\u00d7704",
    "1536\u00d7640": "1536\u00d7640",
    "1600\u00d7640": "1600\u00d7640",
    "1664\u00d7576": "1664\u00d7576",
    "1728\u00d7576": "1728\u00d7576",
    "Image Number": "出图数量",
    "Negative Prompt": "反向提示词",
    "Describing what you do not want to see.": "描述你不想看到的内容。",
    "Random": "随机种子",
    "Seed": "种子",
    "\ud83d\udcda History Log": "\ud83D\uDCDA 历史记录",
    "Image Style": "图像风格",
    "Fooocus V2": "Fooocus V2 风格",
    "Default (Slightly Cinematic)": "默认（轻微的电影感）",
    "Fooocus Masterpiece": "Fooocus - 杰作",
    "Random Style": "随机风格",
    "Fooocus Photograph": "Fooocus - 照片",
    "Fooocus Negative": "Fooocus - 反向提示词",
    "SAI 3D Model": "SAI - 3D模型",
    "SAI Analog Film": "SAI - 模拟电影",
    "SAI Anime": "SAI - 动漫",
    "SAI Cinematic": "SAI - 电影片段",
    "SAI Comic Book": "SAI - 漫画",
    "SAI Craft Clay": "SAI - 工艺粘土",
    "SAI Digital Art": "SAI - 数字艺术",
    "SAI Enhance": "SAI - 增强",
    "SAI Fantasy Art": "SAI - 奇幻艺术",
    "SAI Isometric": "SAI - 等距风格",
    "SAI Line Art": "SAI - 线条艺术",
    "SAI Lowpoly": "SAI - 低多边形",
    "SAI Neonpunk": "SAI - 霓虹朋克",
    "SAI Origami": "SAI - 折纸",
    "SAI Photographic": "SAI - 摄影",
    "SAI Pixel Art": "SAI - 像素艺术",
    "SAI Texture": "SAI - 纹理",
    "MRE Cinematic Dynamic": "MRE - 史诗电影",
    "MRE Spontaneous Picture": "MRE - 自发图片",
    "MRE Artistic Vision": "MRE - 艺术视觉",
    "MRE Dark Dream": "MRE - 黑暗梦境",
    "MRE Gloomy Art": "MRE - 阴郁艺术",
    "MRE Bad Dream": "MRE - 噩梦",
    "MRE Underground": "MRE - 阴森地下",
    "MRE Surreal Painting": "MRE - 超现实主义绘画",
    "MRE Dynamic Illustration": "MRE - 动态插画",
    "MRE Undead Art": "MRE - 遗忘艺术家作品",
    "MRE Elemental Art": "MRE - 元素艺术",
    "MRE Space Art": "MRE - 空间艺术",
    "MRE Ancient Illustration": "MRE - 古代插图",
    "MRE Brave Art": "MRE - 勇敢艺术",
    "MRE Heroic Fantasy": "MRE - 英雄幻想",
    "MRE Dark Cyberpunk": "MRE - 黑暗赛博朋克",
    "MRE Lyrical Geometry": "MRE - 抒情几何抽象画",
    "MRE Sumi E Symbolic": "MRE - 墨绘长笔画",
    "MRE Sumi E Detailed": "MRE - 精细墨绘画",
    "MRE Manga": "MRE - 日本漫画",
    "MRE Anime": "MRE - 日本动画片",
    "MRE Comic": "MRE - 成人漫画书插画",
    "Ads Advertising": "广告 - 广告",
    "Ads Automotive": "广告 - 汽车",
    "Ads Corporate": "广告 - 企业品牌",
    "Ads Fashion Editorial": "广告 - 时尚编辑",
    "Ads Food Photography": "广告 - 美食摄影",
    "Ads Gourmet Food Photography": "广告 - 美食摄影",
    "Ads Luxury": "广告 - 奢侈品",
    "Ads Real Estate": "广告 - 房地产",
    "Ads Retail": "广告 - 零售",
    "Artstyle Abstract": "艺术风格 - 抽象",
    "Artstyle Abstract Expressionism": "艺术风格 - 抽象表现主义",
    "Artstyle Art Deco": "艺术风格 - 装饰艺术",
    "Artstyle Art Nouveau": "艺术风格 - 新艺术",
    "Artstyle Constructivist": "艺术风格 - 构造主义",
    "Artstyle Cubist": "艺术风格 - 立体主义",
    "Artstyle Expressionist": "艺术风格 - 表现主义",
    "Artstyle Graffiti": "艺术风格 - 涂鸦",
    "Artstyle Hyperrealism": "艺术风格 - 超写实主义",
    "Artstyle Impressionist": "艺术风格 - 印象派",
    "Artstyle Pointillism": "艺术风格 - 点彩派",
    "Artstyle Pop Art": "艺术风格 - 波普艺术",
    "Artstyle Psychedelic": "艺术风格 - 迷幻",
    "Artstyle Renaissance": "艺术风格 - 文艺复兴",
    "Artstyle Steampunk": "艺术风格 - 蒸汽朋克",
    "Artstyle Surrealist": "艺术风格 - 超现实主义",
    "Artstyle Typography": "艺术风格 - 字体设计",
    "Artstyle Watercolor": "艺术风格 - 水彩",
    "Futuristic Biomechanical": "未来主义 - 生物机械",
    "Futuristic Biomechanical Cyberpunk": "未来主义 - 生物机械 - 赛博朋克",
    "Futuristic Cybernetic": "未来主义 - 人机融合",
    "Futuristic Cybernetic Robot": "未来主义 - 人机融合 - 机器人",
    "Futuristic Cyberpunk Cityscape": "未来主义 - 赛博朋克城市",
    "Futuristic Futuristic": "未来主义 - 未来主义",
    "Futuristic Retro Cyberpunk": "未来主义 - 复古赛博朋克",
    "Futuristic Retro Futurism": "未来主义 - 复古未来主义",
    "Futuristic Sci Fi": "未来主义 - 科幻",
    "Futuristic Vaporwave": "未来主义 - 蒸汽波",
    "Game Bubble Bobble": "游戏 - 泡泡龙",
    "Game Cyberpunk Game": "游戏 - 赛博朋克游戏",
    "Game Fighting Game": "游戏 - 格斗游戏",
    "Game Gta": "游戏 - 侠盗猎车手",
    "Game Mario": "游戏 - 马里奥",
    "Game Minecraft": "游戏 - 我的世界",
    "Game Pokemon": "游戏 - 宝可梦",
    "Game Retro Arcade": "游戏 - 复古街机",
    "Game Retro Game": "游戏 - 复古游戏",
    "Game Rpg Fantasy Game": "游戏 - 角色扮演幻想游戏",
    "Game Strategy Game": "游戏 - 策略游戏",
    "Game Streetfighter": "游戏 - 街头霸王",
    "Game Zelda": "游戏 - 塞尔达传说",
    "Misc Architectural": "其他 - 建筑",
    "Misc Disco": "其他 - 迪斯科",
    "Misc Dreamscape": "其他 - 梦境",
    "Misc Dystopian": "其他 - 反乌托邦",
    "Misc Fairy Tale": "其他 - 童话故事",
    "Misc Gothic": "其他 - 哥特风",
    "Misc Grunge": "其他 - 垮掉的",
    "Misc Horror": "其他 - 恐怖",
    "Misc Kawaii": "其他 - 可爱",
    "Misc Lovecraftian": "其他 - 洛夫克拉夫特",
    "Misc Macabre": "其他 - 恐怖",
    "Misc Manga": "其他 - 漫画",
    "Misc Metropolis": "其他 - 大都市",
    "Misc Minimalist": "其他 - 极简主义",
    "Misc Monochrome": "其他 - 单色",
    "Misc Nautical": "其他 - 航海",
    "Misc Space": "其他 - 太空",
    "Misc Stained Glass": "其他 - 彩色玻璃",
    "Misc Techwear Fashion": "其他 - 科技时尚",
    "Misc Tribal": "其他 - 部落",
    "Misc Zentangle": "其他 - 禅绕画",
    "Papercraft Collage": "手工艺 - 拼贴",
    "Papercraft Flat Papercut": "手工艺 - 平面剪纸",
    "Papercraft Kirigami": "手工艺 - 切纸",
    "Papercraft Paper Mache": "手工艺 - 纸浆塑造",
    "Papercraft Paper Quilling": "手工艺 - 纸艺卷轴",
    "Papercraft Papercut Collage": "手工艺 - 剪纸拼贴",
    "Papercraft Papercut Shadow Box": "手工艺 - 剪纸影箱",
    "Papercraft Stacked Papercut": "手工艺 - 层叠剪纸",
    "Papercraft Thick Layered Papercut": "手工艺 - 厚层剪纸",
    "Photo Alien": "摄影 - 外星人",
    "Photo Film Noir": "摄影 - 黑色电影",
    "Photo Glamour": "摄影 - 魅力",
    "Photo Hdr": "摄影 - 高动态范围",
    "Photo Iphone Photographic": "摄影 - 苹果手机摄影",
    "Photo Long Exposure": "摄影 - 长曝光",
    "Photo Neon Noir": "摄影 - 霓虹黑色",
    "Photo Silhouette": "摄影 - 轮廓",
    "Photo Tilt Shift": "摄影 - 移轴",
    "Cinematic Diva": "电影女主角",
    "Abstract Expressionism": "抽象表现主义",
    "Academia": "学术",
    "Action Figure": "动作人偶",
    "Adorable 3D Character": "可爱的3D角色",
    "Adorable Kawaii": "可爱的卡哇伊",
    "Art Deco": "装饰艺术",
    "Art Nouveau": "新艺术，美丽艺术",
    "Astral Aura": "星体光环",
    "Avant Garde": "前卫",
    "Baroque": "巴洛克",
    "Bauhaus Style Poster": "包豪斯风格海报",
    "Blueprint Schematic Drawing": "蓝图示意图",
    "Caricature": "漫画",
    "Cel Shaded Art": "卡通渲染",
    "Character Design Sheet": "角色设计表",
    "Classicism Art": "古典主义艺术",
    "Color Field Painting": "色彩领域绘画",
    "Colored Pencil Art": "彩色铅笔艺术",
    "Conceptual Art": "概念艺术",
    "Constructivism": "建构主义",
    "Cubism": "立体主义",
    "Dadaism": "达达主义",
    "Dark Fantasy": "黑暗奇幻",
    "Dark Moody Atmosphere": "黑暗忧郁气氛",
    "Dmt Art Style": "迷幻艺术风格",
    "Doodle Art": "涂鸦艺术",
    "Double Exposure": "双重曝光",
    "Dripping Paint Splatter Art": "滴漆飞溅艺术",
    "Expressionism": "表现主义",
    "Faded Polaroid Photo": "褪色的宝丽来照片",
    "Fauvism": "野兽派",
    "Flat 2d Art": "平面 2D 艺术",
    "Fortnite Art Style": "堡垒之夜艺术风格",
    "Futurism": "未来派",
    "Glitchcore": "故障核心",
    "Glo Fi": "光明高保真",
    "Googie Art Style": "古吉艺术风格",
    "Graffiti Art": "涂鸦艺术",
    "Harlem Renaissance Art": "哈莱姆文艺复兴艺术",
    "High Fashion": "高级时装",
    "Idyllic": "田园诗般",
    "Impressionism": "印象派",
    "Infographic Drawing": "信息图表绘图",
    "Ink Dripping Drawing": "滴墨绘画",
    "Japanese Ink Drawing": "日式水墨画",
    "Knolling Photography": "规律摆放摄影",
    "Light Cheery Atmosphere": "轻松愉快的气氛",
    "Logo Design": "标志设计",
    "Luxurious Elegance": "奢华优雅",
    "Macro Photography": "微距摄影",
    "Mandola Art": "曼陀罗艺术",
    "Marker Drawing": "马克笔绘图",
    "Medievalism": "中世纪主义",
    "Minimalism": "极简主义",
    "Neo Baroque": "新巴洛克",
    "Neo Byzantine": "新拜占庭",
    "Neo Futurism": "新未来派",
    "Neo Impressionism": "新印象派",
    "Neo Rococo": "新洛可可",
    "Neoclassicism": "新古典主义",
    "Op Art": "欧普艺术",
    "Ornate And Intricate": "华丽而复杂",
    "Pencil Sketch Drawing": "铅笔素描",
    "Pop Art 2": "流行艺术2",
    "Rococo": "洛可可",
    "Silhouette Art": "剪影艺术",
    "Simple Vector Art": "简单矢量艺术",
    "Sketchup": "草图",
    "Steampunk 2": "赛博朋克2",
    "Surrealism": "超现实主义",
    "Suprematism": "至上主义",
    "Terragen": "地表风景",
    "Tranquil Relaxing Atmosphere": "宁静轻松的氛围",
    "Sticker Designs": "贴纸设计",
    "Vibrant Rim Light": "生动的边缘光",
    "Volumetric Lighting": "体积照明",
    "Watercolor 2": "水彩2",
    "Whimsical And Playful": "异想天开、俏皮",
    "Fooocus Cinematic": "Fooocus - 电影",
    "Fooocus Enhance": "Fooocus - 增强",
    "Fooocus Sharp": "Fooocus - 锐化",
    "Mk Chromolithography": "MK - 彩色平版印刷",
    "Mk Cross Processing Print": "MK - 交叉处理",
    "Mk Dufaycolor Photograph": "MK - 杜菲色",
    "Mk Herbarium": "MK - 标本",
    "Mk Punk Collage": "MK - 拼贴朋克",
    "Mk Mosaic": "MK - 马赛克",
    "Mk Van Gogh": "MK - 梵高",
    "Mk Coloring Book": "MK - 简笔画",
    "Mk Singer Sargent": "MK - 辛格·萨金特",
    "Mk Pollock": "MK - 波洛克",
    "Mk Basquiat": "MK - 巴斯奇亚",
    "Mk Andy Warhol": "MK - 安迪·沃霍尔",
    "Mk Halftone Print": "MK - 半色调",
    "Mk Gond Painting": "MK - 贡德艺术",
    "Mk Albumen Print": "MK - 蛋白银印相",
    "Mk Inuit Carving": "MK - 因纽特雕塑艺术",
    "Mk Bromoil Print": "MK - 溴油印",
    "Mk Calotype Print": "MK - 卡洛型",
    "Mk Color Sketchnote": "MK - 涂鸦",
    "Mk Cibulak Porcelain": "MK - 蓝洋葱",
    "Mk Alcohol Ink Art": "MK - 墨画",
    "Mk One Line Art": "MK - 单线艺术",
    "Mk Blacklight Paint": "MK - 黑白艺术",
    "Mk Carnival Glass": "MK - 彩虹色玻璃",
    "Mk Cyanotype Print": "MK - 蓝晒",
    "Mk Cross Stitching": "MK - 十字绣",
    "Mk Encaustic Paint": "MK - 热蜡画",
    "Mk Embroidery": "MK - 刺绣",
    "Mk Gyotaku": "MK - 鱼拓",
    "Mk Luminogram": "MK - 发光图",
    "Mk Lite Brite Art": "MK - 灯光创意",
    "Mk Mokume Gane": "MK - 木目金",
    "Pebble Art": "鹅卵石艺术",
    "Mk Palekh": "MK - 缩影",
    "Mk Suminagashi": "MK - 漂浮墨水",
    "Mk Scrimshaw": "MK - 斯克林肖",
    "Mk Shibori": "MK - 手工扎染",
    "Mk Vitreous Enamel": "MK - 搪瓷",
    "Mk Ukiyo E": "MK - 浮世绘",
    "Mk Vintage Airline Poster": "MK - 复古艺术",
    "Mk Vintage Travel Poster": "MK - 复古艺术旅行",
    "Mk Bauhaus Style": "MK - 包豪斯设计风格",
    "Mk Afrofuturism": "MK - 未来主义",
    "Mk Atompunk": "MK - 原子朋克",
    "Mk Constructivism": "MK - 建构",
    "Mk Chicano Art": "MK - 奇卡诺艺术",
    "Mk De Stijl": "MK - 荷兰风格",
    "Mk Dayak Art": "MK - 达雅克艺术",
    "Mk Fayum Portrait": "MK - 法尤姆风格",
    "Mk Illuminated Manuscript": "MK - 泥金装饰手抄",
    "Mk Kalighat Painting": "MK - 卡利加特绘画",
    "Mk Madhubani Painting": "MK - 马杜巴尼艺术",
    "Mk Pictorialism": "MK - 绘画摄影",
    "Mk Pichwai Painting": "MK - 皮切瓦伊",
    "Mk Patachitra Painting": "MK - 粘土艺术",
    "Mk Samoan Art Inspired": "MK - 萨摩亚艺术",
    "Mk Tlingit Art": "MK - 特林吉特艺术",
    "Mk Adnate Style": "MK - 具象艺术",
    "Mk Ron English Style": "MK - 罗恩·英格利斯",
    "Mk Shepard Fairey Style": "MK - 街头艺术",
    "Fooocus Semi Realistic": "Fooocus - 半现实风格",
    "Mk Anthotype Print": "MK - 花汁印相",
    "Mk Aquatint Print": "MK - 飞尘腐蚀版画",
    "Model": "模型",
    "Base Model (SDXL only)": "基础模型（只支持 SDXL）",
    "Refiner (SDXL or SD 1.5)": "精修模型 （支持 SDXL 或 SD 1.5）",
    "None": "无",
    "LoRAs": "LoRAs 模型",
    "SDXL LoRA 1": "SDXL LoRA 模型 1",
    "SDXL LoRA 2": "SDXL LoRA 模型 2",
    "SDXL LoRA 3": "SDXL LoRA 模型 3",
    "SDXL LoRA 4": "SDXL LoRA 模型 4",
    "SDXL LoRA 5": "SDXL LoRA 模型 5",
    "LoRA 1": "LoRA 模型 1",
    "LoRA 2": "LoRA 模型 2",
    "LoRA 3": "LoRA 模型 3",
    "LoRA 4": "LoRA 模型 4",
    "LoRA 5": "LoRA 模型 5",
    "Refresh": "Refresh",
    "\ud83d\udd04 Refresh All Files": "\ud83d\udd04 刷新全部文件",
    "Sampling Sharpness": "采样清晰度",
    "Higher value means image and texture are sharper.": "值越大，图像和纹理越清晰。",
    "Guidance Scale": "提示词引导系数",
    "Higher value means style is cleaner, vivider, and more artistic.": "提示词作用的强度，值越大，风格越干净、生动、更具艺术感。",
    "Developer Debug Mode": "开发者调试模式",
    "Developer Debug Tools": "开发者调试工具",
    "Positive ADM Guidance Scaler": "正向 ADM 引导系数",
    "The scaler multiplied to positive ADM (use 1.0 to disable). ": "正向 ADM 引导的倍率 （使用 1.0 以禁用）。 ",
    "Negative ADM Guidance Scaler": "负向 ADM 引导系数",
    "The scaler multiplied to negative ADM (use 1.0 to disable). ": "负向 ADM 引导的倍率（使用 1.0 以禁用）。 ",
    "ADM Guidance End At Step": "ADM 引导结束步长",
    "When to end the guidance from positive/negative ADM. ": "正向 / 负向 ADM 结束引导的时间。 ",
    "Refiner swap method": "Refiner 精炼模型交换方式",
    "joint": "joint 联合",
    "separate": "separate 分离",
    "vae": "vae 变分自编码器",
    "CFG Mimicking from TSNR": "从 TSNR 模拟 CFG",
    "Enabling Fooocus's implementation of CFG mimicking for TSNR (effective when real CFG > mimicked CFG).": "启用 Fooocus 的 TSNR 模拟 CFG 的功能（当真实的 CFG 大于模拟的 CFG 时生效）。",
    "Sampler": "采样器",
    "dpmpp_2m_sde_gpu": "dpmpp_2m_sde_gpu",
    "Only effective in non-inpaint mode.": "仅在非重绘模式下有效。",
    "euler": "euler",
    "euler_ancestral": "euler_ancestral",
    "heun": "heun",
    "dpm_2": "dpm_2",
    "dpm_2_ancestral": "dpm_2_ancestral",
    "lms": "lms",
    "dpm_fast": "dpm_fast",
    "dpm_adaptive": "dpm_adaptive",
    "dpmpp_2s_ancestral": "dpmpp_2s_ancestral",
    "dpmpp_sde": "dpmpp_sde",
    "dpmpp_sde_gpu": "dpmpp_sde_gpu",
    "dpmpp_2m": "dpmpp_2m",
    "dpmpp_2m_sde": "dpmpp_2m_sde",
    "dpmpp_3m_sde": "dpmpp_3m_sde",
    "dpmpp_3m_sde_gpu": "dpmpp_3m_sde_gpu",
    "ddpm": "ddpm",
    "ddim": "ddim",
    "uni_pc": "uni_pc",
    "uni_pc_bh2": "uni_pc_bh2",
    "Scheduler": "调度器",
    "karras": "karras",
    "Scheduler of Sampler.": "采样器的调度器。",
    "normal": "normal",
    "exponential": "exponential",
    "sgm_uniform": "sgm_uniform",
    "simple": "simple",
    "ddim_uniform": "ddim_uniform",
    "Forced Overwrite of Sampling Step": "强制覆盖采样步长",
    "Set as -1 to disable. For developer debugging.": "设为 -1 以禁用。用于开发者调试。",
    "Forced Overwrite of Refiner Switch Step": "强制重写精炼器开关步数",
    "Forced Overwrite of Generating Width": "强制覆盖生成宽度",
    "Set as -1 to disable. For developer debugging. Results will be worse for non-standard numbers that SDXL is not trained on.": "设为 -1 以禁用。用于开发者调试。对于 SDXL 没有训练过的非标准数字，结果会差。",
    "Forced Overwrite of Generating Height": "强制覆盖生成高度",
    "Forced Overwrite of Denoising Strength of \"Vary\"": "强制覆盖“变化”的去噪强度",
    "Set as negative number to disable. For developer debugging.": "设为负数以禁用。用于开发者调试。",
    "Forced Overwrite of Denoising Strength of \"Upscale\"": "强制覆盖“放大”去噪强度",
    "Inpaint Engine": "重绘引擎",
    "v1": "v1",
    "Version of Fooocus inpaint model": "重绘模型的版本选择",
    "v2.5": "v2.5",
    "Control Debug": "控制调试",
    "Debug Preprocessors": "启用预处理器结果展示",
    "Mixing Image Prompt and Vary/Upscale": "混合图生图和变化 / 放大",
    "Mixing Image Prompt and Inpaint": "混合图生图和重绘",
    "Softness of ControlNet": "ControlNet 控制权重",
    "Similar to the Control Mode in A1111 (use 0.0 to disable). ": "类似于 SD WebUI 中的控制模式（使用 0.0 来禁用）。 ",
    "Canny": "Canny 边缘检测算法",
    "Canny Low Threshold": "Canny 最低阈值",
    "Canny High Threshold": "Canny 最高阈值",
    "FreeU": "FreeU 提示词精准性优化",
    "Enabled": "启用",
    "B1": "B1",
    "B2": "B2",
    "S1": "S1",
    "S2": "S2",
    "Type prompt here.": "在这里输入反向提示词（请用英文逗号分隔）",
    "wheel": "滚轮",
    "Zoom canvas": "画布缩放",
    "Adjust brush size": "调整笔刷尺寸",
    "Reset zoom": "画布复位",
    "Fullscreen mode": "全屏模式",
    "Move canvas": "移动画布",
    "Overlap": "图层重叠",
    "Preset": "预设配置",
    "Output Format": "图片保存格式",
    "Type prompt here or paste parameters.": "在这里输入提示词（请用英文逗号分隔）",
    "\uD83D\uDD0E Type here to search styles ...": "\uD83D\uDD0E 搜索风格预设 ...",
    "Image Sharpness": "图像锐化",
    "Debug Tools": "调试工具",
    "Control": "ControlNet 设置",
    "See the results from preprocessors.": "显示预处理处理结果选项",
    "Do not preprocess images. (Inputs are already canny/depth/cropped-face/etc.)": "不对图像进行预处理 (导入的图像要求是 边缘控制图 / 深度图 / 面部特征图 / 其他)",
    "Skip Preprocessors": "禁用图片预处理",
    "Inpaint": "重绘设置",
    "Debug Inpaint Preprocessing": "启用重绘预处理功能调试",
    "Disable initial latent in inpaint": "禁用在重绘中初始化潜空间",
    "Inpaint Denoising Strength": "重绘幅度",
    "Same as the denoising strength in A1111 inpaint. Only used in inpaint, not used in outpaint. (Outpaint always use 1.0)": "该选项和 A1111 SD WebUI 中重绘功能的重绘幅度相同。该选项仅应用于图生图重绘功能中，在文生图中该设置无效（在文生图中该值为 1.0）",
    "Inpaint Respective Field": "重绘蒙版区域范围",
    "The area to inpaint. Value 0 is same as \"Only Masked\" in A1111. Value 1 is same as \"Whole Image\" in A1111. Only used in inpaint, not used in outpaint. (Outpaint always use 1.0)": "调整重绘区域的范围。该值为 0 时和 A1111 SD WebUI 中“重绘区域”选项的“仅蒙版区域”的效果相同，为 1 时和“整张图片”效果相同。该选项仅应用于图生图重绘功能中，在文生图中该设置无效（在文生图中该值为 1.0）",
    "Mask Erode or Dilate": "蒙版范围调整",
    "Positive value will make white area in the mask larger, negative value will make white area smaller.(default is 0, always process before any mask invert)": "正值将使蒙版中的白色区域变大，负值将使白色区域变小。（默认值为 0，始终在任何蒙版反转之前进行处理）",
    "Enable Mask Upload": "启用蒙版上传功能",
    "Invert Mask": "反转蒙版（重绘非蒙版内容）",
    "ImagePrompt": "图像作为提示次输入",
    "FaceSwap": "面部更改",
    "Drag inpaint or outpaint image to here": "导入需要重绘的图片",
    "Inpaint or Outpaint": "图片重绘",
    "Method": "功能",
    "Inpaint or Outpaint (default)": "图片重绘（默认）",
    "Improve Detail (face, hand, eyes, etc.)": "提升细节（面部，手，眼睛等）",
    "Modify Content (add objects, change background, etc.)": "修改内容（添加对象、更改背景等）",
    "Outpaint Direction": "图片扩充方向",
    "Additional Prompt Quick List": "附加提示词快速添加列表",
    "Inpaint Additional Prompt": "重绘附加提示词",
    "Describe what you want to inpaint.": "描述你想要重绘的",
    "* Powered by Fooocus Inpaint Engine": "* 由 Fooocus 重绘引擎驱动",
    "Describe": "图像提示词反推",
    "Drag any image to here": "导入任意图片",
    "Content Type": "图片内容种类",
    "Photograph": "照片",
    "Art/Anime": "画作 / 动漫图片",
    "Describe this Image into Prompt": "反推图片的提示词",
    "Metadata": "图片信息查看",
    "Drag any image generated by Fooocus here": "导入由 Fooocus 生成的图片",
    "Apply Metadata": "应用图片信息",
    "(Experimental) This may cause performance problems on some computers and certain internet conditions.": "（实验性）这可能会在某些计算机和某些互联网条件下导致性能问题。",
    "Generate Image Grid for Each Batch": "为每个批次生成图像网格",
    "Disable preview during generation.": "在图片生成时禁用过程预览",
    "Disable Preview": "禁用预览",
    "Disable intermediate results during generation, only show final gallery.": "在生成过程中禁用生成的中间结果，仅显示最终图库。",
    "Disable Intermediate Results": "禁用中间生成结果",
    "Disable automatic seed increment when image number is > 1.": "当图片生成批次大于 1 时禁用种子增量",
    "Disable seed increment": "禁用种子增量",
    "Read wildcards in order": "按顺序读取通配符",
    "Adds parameters to generated images allowing manual regeneration.": "在生成的图片中添加元数据（提示词信息等）便于复现原图",
    "Save Metadata to Images": "保存元数据到图像中",
    "Metadata Scheme": "元数据格式",
    "Image Prompt parameters are not included. Use png and a1111 for compatibility with Civitai.": "使用默认设置时图片提示词参数不包括在内。使用 png 图片保存格式和 A1111 SD WebUI 的图片信息保存风格的图片更适合在 Civitai 进行分享。",
    "fooocus (json)": "Fooocus 风格（json）",
    "a1111 (plain text)": "A1111 SD WebUI 风格（纯文本）",
    "Refiner Switch At": "Refind 切换时机",
    "Use 0.4 for SD1.5 realistic models; or 0.667 for SD1.5 anime models; or 0.8 for XL-refiners; or any value for switching two SDXL models.": "SD 1.5 真实模型使用 0.4，SD1.5 动漫模型为 0.667，XLRefind 机为 0.8，或用于切换两个 SDXL 模型的任何值。",
    "Waiting for task to start ...": "等待任务开始 ...",
    "Connection errored out.": "连接超时",
    "Error": "错误",
    "error": "错误",
    "Loading...": "加载中 ...",
    "Moving model to GPU ...": "将模型移至 GPU ...",
    "Loading models ...": "加载模型 ...",
    "VAE encoding ...": "VAE 编码 ...",
    "Image processing ...": "处理图像 ...",
    "Processing prompts ...": "处理提示词 ...",
    "Download": "下载",
    "Downloading control models ...": "下载 ControlNet 模型 ...",
    "Loading control models ...": "加载 ControlNet 模型 ...",
    "processing": "处理中",
    "Downloading upscale models ...": "下载放大模型 ...",
    "Downloading inpainter ...": "下载重绘模型 ...",
    "Use via API": "通过 API 调用",
    "Lost connection due to leaving page. Rejoining queue...": "由于离开页面而失去连接。正在重新加入队列 ...",
    "warning": "警告",
    "Warning": "警告",
    "Finished Images": "已完成的图像",
    "On mobile, the connection can break if this tab is unfocused or the device sleeps, losing your position in queue.": "在移动端上，如果此选项卡无焦点或设备休眠，连接可能中断，从而失去队列中的位置。",
    "Initializing ...": "初始化 ...",
    "Downloading LCM components ...": "下载 LCM 组件 ...",
    "Downloading Lightning components ...": "下载 Lightning 组件 ...",
    "Start drawing": "开始涂鸦",
    "VAE Inpaint encoding ...": "VAE 重绘编码 ...",
    "JSON.parse: unexpected character at line 2 column 1 of the JSON data": "JSON 分析：JSON 数据中第 2 行第 1 列出现不期望字符",
    "API documentation": "API 文档",
    "fn_index:": "主要方法: ",
    "Use the": "使用",
    "Python library or the": "Python 库或者",
    "Javascript package to query the demo via API.": "Javascript 包来查询演示 API。",
    "Unnamed Endpoints": "未命名接口",
    "Return Type(s)": "返回类型",
    "47 API endpoints": "47 个 API 接口",
    "copy": "复制",
    "copied!": "已复制！",
    "JSON.parse: unexpected character at line 1 column 1 of the JSON data": "JAVA 解析：JSON 数据第 1 行第 1 列出现意外字符",
    "Generate forever": "无限生成",
    "Downloading Hyper-SD components ...": "下载 Hyper SD 组件中 ...",
    "Inpaint brush color": "重绘画笔颜色",
    "CLIP Skip": "CLIP 跳过层数",
    "Bypass CLIP layers to avoid overfitting (use 1 to not skip any layers, 2 is recommended).": "CLIP 跳过层数可避免过拟合的情况（使用 1 为不跳过任何层，2 为推荐值）",
    "VAE": "VAE 模型",
    "Default (model)": "默认（模型）",
    "Use black image if NSFW is detected.": "当检测到图片存在 NSFW 内容时将屏蔽图片",
    "Black Out NSFW": "屏蔽 NSFW",
    "For images created by Fooocus": "导入由 Fooocus 生成的图片",
    "- Zoom canvas": " - 缩放画布",
    "- Adjust brush size": " - 调整画笔大小",
    "- Undo last action": "- 撤回上一次的操作",
    "- Reset zoom": " - 重置缩放",
    "- Fullscreen mode": " - 全屏模式",
    "- Move canvas": " - 移动画布",
    "Image Size and Recommended Size": "图片分辨率和推荐的生图分辨率"
}
EOF
}
