#!/bin/bash

# 检查显卡是否可以支持 CUDA 内存分配器(Python)
py_check_cuda_malloc_avaliable() {
    cat<<EOF
import os
import importlib.util
import subprocess

#Can't use pytorch to get the GPU names because the cuda malloc has to be set before the first import.
def get_gpu_names():
    if os.name == 'nt':
        import ctypes

        # Define necessary C structures and types
        class DISPLAY_DEVICEA(ctypes.Structure):
            _fields_ = [
                ('cb', ctypes.c_ulong),
                ('DeviceName', ctypes.c_char * 32),
                ('DeviceString', ctypes.c_char * 128),
                ('StateFlags', ctypes.c_ulong),
                ('DeviceID', ctypes.c_char * 128),
                ('DeviceKey', ctypes.c_char * 128)
            ]

        # Load user32.dll
        user32 = ctypes.windll.user32

        # Call EnumDisplayDevicesA
        def enum_display_devices():
            device_info = DISPLAY_DEVICEA()
            device_info.cb = ctypes.sizeof(device_info)
            device_index = 0
            gpu_names = set()

            while user32.EnumDisplayDevicesA(None, device_index, ctypes.byref(device_info), 0):
                device_index += 1
                gpu_names.add(device_info.DeviceString.decode('utf-8'))
            return gpu_names
        return enum_display_devices()
    else:
        gpu_names = set()
        out = subprocess.check_output(['nvidia-smi', '-L'])
        for l in out.split(b'\n'):
            if len(l) > 0:
                gpu_names.add(l.decode('utf-8').split(' (UUID')[0])
        return gpu_names

blacklist = {"GeForce GTX TITAN X", "GeForce GTX 980", "GeForce GTX 970", "GeForce GTX 960", "GeForce GTX 950", "GeForce 945M",
                "GeForce 940M", "GeForce 930M", "GeForce 920M", "GeForce 910M", "GeForce GTX 750", "GeForce GTX 745", "Quadro K620",
                "Quadro K1200", "Quadro K2200", "Quadro M500", "Quadro M520", "Quadro M600", "Quadro M620", "Quadro M1000",
                "Quadro M1200", "Quadro M2000", "Quadro M2200", "Quadro M3000", "Quadro M4000", "Quadro M5000", "Quadro M5500", "Quadro M6000",
                "GeForce MX110", "GeForce MX130", "GeForce 830M", "GeForce 840M", "GeForce GTX 850M", "GeForce GTX 860M",
                "GeForce GTX 1650", "GeForce GTX 1630", "Tesla M4", "Tesla M6", "Tesla M10", "Tesla M40", "Tesla M60"
                }

def cuda_malloc_supported():
    try:
        names = get_gpu_names()
    except:
        names = set()
    for x in names:
        if "NVIDIA" in x:
            for b in blacklist:
                if b in x:
                    return False
    return True



try:
    version = ""
    torch_spec = importlib.util.find_spec("torch")
    for folder in torch_spec.submodule_search_locations:
        ver_file = os.path.join(folder, "version.py")
        if os.path.isfile(ver_file):
            spec = importlib.util.spec_from_file_location("torch_version_import", ver_file)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)
            version = module.__version__
    if int(version[0]) >= 2: #enable by default for torch version 2.0 and up
        print(cuda_malloc_supported())
    else:
        print(False)
except:
    print(None)
    pass
EOF
}

# 检查显卡是否为 Nvidia 显卡(Python)
py_check_gpu_is_nvidia_drive() {
    cat<<EOF
import os
import importlib.util
import subprocess

#Can't use pytorch to get the GPU names because the cuda malloc has to be set before the first import.
def get_gpu_names():
    if os.name == 'nt':
        import ctypes

        # Define necessary C structures and types
        class DISPLAY_DEVICEA(ctypes.Structure):
            _fields_ = [
                ('cb', ctypes.c_ulong),
                ('DeviceName', ctypes.c_char * 32),
                ('DeviceString', ctypes.c_char * 128),
                ('StateFlags', ctypes.c_ulong),
                ('DeviceID', ctypes.c_char * 128),
                ('DeviceKey', ctypes.c_char * 128)
            ]

        # Load user32.dll
        user32 = ctypes.windll.user32

        # Call EnumDisplayDevicesA
        def enum_display_devices():
            device_info = DISPLAY_DEVICEA()
            device_info.cb = ctypes.sizeof(device_info)
            device_index = 0
            gpu_names = set()

            while user32.EnumDisplayDevicesA(None, device_index, ctypes.byref(device_info), 0):
                device_index += 1
                gpu_names.add(device_info.DeviceString.decode('utf-8'))
            return gpu_names
        return enum_display_devices()
    else:
        gpu_names = set()
        out = subprocess.check_output(['nvidia-smi', '-L'])
        for l in out.split(b'\n'):
            if len(l) > 0:
                gpu_names.add(l.decode('utf-8').split(' (UUID')[0])
        return gpu_names

def is_nvidia_gpu():
    try:
        names = get_gpu_names()
    except:
        names = set()
    for x in names:
        if "NVIDIA" in x:
            return True
    return False



print(is_nvidia_gpu())
EOF
}

# 返回 CUDA 内存分配器可用状态
is_cuda_malloc_avaliable() {
    local req

    req=$(term_sd_python -c "$(py_check_cuda_malloc_avaliable)")

    if [[ "${req}" == True ]]; then
        return 0
    else
        return 1
    fi
}

# 返回显示是否为 Nvidia 显卡的状态
check_gpu_is_nvidia_drive() {
    local req

    req=$(term_sd_python -c "$(py_check_gpu_is_nvidia_drive)")

    if [[ "${req}" == True ]]; then
        return 0
    else
        return 1
    fi
}