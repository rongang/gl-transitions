// Author:rongang
// License: MIT
// 转场进度 (0.0 到 1.0)
// 第一段视频纹理
// 第二段视频纹理
// 视频分辨率
uniform float strength; // = 1

// 模拟透视效果的函数
vec2 zoom(vec2 uv, float amount) {
    // 以中心为基点进行缩放
    return (uv - 0.5) / amount + 0.5;
}

const float PI = 3.141592653589793;

float Linear_ease(in float begin, in float change, in float duration, in float time) {
    return change * time / duration + begin;
}

float Exponential_easeInOut(in float begin, in float change, in float duration, in float time) {
    if (time == 0.0)
        return begin;
    else if (time == duration)
        return begin + change;
    time = time / (duration / 2.0);
    if (time < 1.0)
        return change / 2.0 * pow(2.0, 10.0 * (time - 1.0)) + begin;
    return change / 2.0 * (-pow(2.0, -10.0 * (time - 1.0)) + 2.0) + begin;
}

float Sinusoidal_easeInOut(in float begin, in float change, in float duration, in float time) {
    return -change / 2.0 * (cos(PI * time / duration) - 1.0) + begin;
}

float rand (vec2 co) {
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 crossFade(in vec2 uv,in vec2 uv2, in float dissolve) {
      // 定义缩放的参数。进度控制视频的缩放程度
    float zoomFrom = mix(1.0, 2.0,  Exponential_easeInOut(0.0, 1.0, 0.6, progress)); // 第一段视频从 1x 缩小到 2x
    float zoomTo = mix(0.9, 1.0,  Exponential_easeInOut(0.0, 1.0, 0.8, progress));   // 第二段视频从 0.5x 放大到 1x
    return mix(getFromColor(zoom(uv, zoomFrom)).rgb, getToColor(zoom(uv2, zoomTo)).rgb, dissolve);
}


vec4 transition(vec2 uv) {
    vec2 texCoord = uv.xy / vec2(1.0).xy;
    
    // 固定中心点为(0.5, 0.5)
    vec2 center = vec2(0.5, 0.5);

    // 定义缩放的参数。进度控制视频的缩放程度
    float zoomFrom = mix(1.0, 2.0, progress); // 第一段视频从 1x 缩小到 2x
    float zoomTo = mix(0.8, 1.0, progress);   // 第二段视频从 0.5x 放大到 1x

    // 缩放每个视频
    // vec4 colorFrom = getFromColor(zoom(uv1, zoomFrom));
    // vec4 colorTo = getToColor(zoom(uv1, zoomTo));
    
    // 渐变控制
    float dissolve = Exponential_easeInOut(0.0, 1.0, 1.0, progress);
    
    // 模糊强度通过 Sinusoidal_easeInOut 缓和
    float blurStrength = Sinusoidal_easeInOut(0.0, strength, 0.5, progress);
    
    vec3 color = vec3(0.0);
    float total = 0.0;
    vec2 toCenter = center - texCoord;

    // 随机偏移
    float offset = rand(uv);
    
    // 径向模糊
    for (float t = 0.0; t <= 20.0; t++) {
        float percent = (t + offset) / 20.0;
        float weight = 4.0 * (percent - percent * percent);
        
        // 结合缩放和模糊的 crossFade
        color += crossFade(texCoord + toCenter * percent * blurStrength,texCoord, dissolve) * weight;
        total += weight;
    }

    return vec4(color / total, 1.0);
}
