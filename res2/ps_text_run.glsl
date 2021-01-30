//
//
// Hello, future bug hunter!
// I hope you have come to reduce this testcase further.
//
// Keep scrolling down until you find "HERE IS THE BUG".
//
//
//


#if defined(WR_VERTEX_SHADER) && defined(WR_FEATURE_ALPHA_PASS) && \
    defined(WR_FEATURE_TEXTURE_2D) && \
    !defined(WR_FEATURE_DEBUG) && \
    !defined(WR_FEATURE_GLYPH_TRANSFORM) && \
    !defined(WR_FEATURE_DUAL_SOURCE_BLENDING) && \
    !defined(SWGL)

precision highp int;

// ps_text_run
// features: ["ALPHA_PASS", "TEXTURE_2D"]

struct RectWithSize {
  vec2 p0;
  vec2 size;
};
uniform int uMode;
uniform mat4 uTransform;
in vec2 aPosition;
uniform sampler2D sColor0;
uniform sampler2D sRenderTasks;
uniform sampler2D sGpuCache;
uniform sampler2D sTransformPalette;
uniform sampler2D sPrimitiveHeadersF;
uniform isampler2D sPrimitiveHeadersI;
in ivec4 aData;
flat out vec4 v_color;

void main ()
{
  vec2 glyph_offset_1;
  int color_mode_2;
  int instance_picture_task_address_5;
  int instance_flags_8;
  int instance_resource_address_9;
  instance_picture_task_address_5 = (aData.y >> 16);
  instance_flags_8 = (aData.z >> 16);
  color_mode_2  = (instance_flags_8 & 255);
  instance_resource_address_9 = (aData.w & 16777215);
  ivec2 tmpvar_10;
  tmpvar_10.x = int((2u * (
    uint(aData.x)
   % 512u)));
  tmpvar_10.y = int((uint(aData.x) / 512u));
  vec4 tmpvar_11;
  tmpvar_11 = texelFetchOffset (sPrimitiveHeadersF, tmpvar_10, 0, ivec2(0, 0));
  mat4 transform_m_15;
  
  // even though transform_m_15[2] is not read it's important for this test
  transform_m_15[2] = texelFetchOffset (sTransformPalette, ivec2(0, 0), 0, ivec2(2, 0));
  
  ivec2 tmpvar_31;
  tmpvar_31.x = int((uint(0) % 1024u));
  tmpvar_31.y = int((uint(0) / 1024u));
  vec4 tmpvar_32;
  vec4 tmpvar_33;
  tmpvar_32 = texelFetchOffset (sGpuCache, tmpvar_31, 0, ivec2(0, 0));
  tmpvar_33 = texelFetchOffset (sGpuCache, tmpvar_31, 0, ivec2(1, 0));
  int tmpvar_34;
  tmpvar_34 = ((0 + 2) + int((
    uint(0)
   / 2u)));
  ivec2 tmpvar_35;
  tmpvar_35.x = int((uint(tmpvar_34) % 1024u));
  tmpvar_35.y = int((uint(tmpvar_34) / 1024u));
  vec4 tmpvar_36;
  tmpvar_36 = texelFetch (sGpuCache, tmpvar_35, 0);
  glyph_offset_1 = (mix(tmpvar_36.xy, tmpvar_36.zw, bvec2((
    (uint(0) % 2u)
   != uint(0)))) + tmpvar_11.xy);
  ivec2 tmpvar_37;
  tmpvar_37.x = int((uint(instance_resource_address_9) % 1024u));
  tmpvar_37.y = int((uint(instance_resource_address_9) / 1024u));
  vec4 tmpvar_38;
  tmpvar_38 = texelFetchOffset (sGpuCache, tmpvar_37, 0, ivec2(0, 0));
  float tmpvar_41 = 2;
  vec2 tmpvar_43;
  vec2 tmpvar_44;
  tmpvar_43 = (1 / tmpvar_41 * ( glyph_offset_1 * tmpvar_41 ));
  tmpvar_44 = ((1 / tmpvar_41)* (tmpvar_38.zw - tmpvar_38.xy));
  vec2 tmpvar_45;
  tmpvar_45 = (tmpvar_43 +
    (tmpvar_44 * aPosition)
  );
  
  vec4 tmpvar_48;
  tmpvar_48.xy = ((tmpvar_45.xy * 2));
  tmpvar_48.z = 0;
  tmpvar_48.w = 1;
  gl_Position = (uTransform * tmpvar_48);

  //
  //
  // HERE IS THE BUG
  //
  // color_mode_2 is 1, but the first if branch is not entered.
  // The second if branch is entered!
  //
  // Blue text: things work correctly
  // Black text: the bug appears
  // Purple text: unexpected
  //
  if (color_mode_2 == 1) {
    v_color = vec4(0.0, 0.0, 1.0, 1.0); // blue
  } else if (color_mode_2 + 3 == 4) {
    v_color = vec4(0.0, 0.0, 0.0, 1.0); // black
  } else {
    v_color = vec4(1.0, 0.0, 1.0, 1.0); // purple
  };

}



#else
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include shared,prim_shared

flat varying vec4 v_color;
// Normalized bounds of the source image in the texture.

// Interpolated UV coordinates to sample.



#ifdef WR_VERTEX_SHADER

#define VECS_PER_TEXT_RUN           2
#define GLYPHS_PER_GPU_BLOCK        2U


struct Glyph {
    vec2 offset;
};

Glyph fetch_glyph(int specific_prim_address,
                  int glyph_index) {
    // Two glyphs are packed in each texel in the GPU cache.
    int glyph_address = specific_prim_address +
                        VECS_PER_TEXT_RUN +
                        int(uint(glyph_index) / GLYPHS_PER_GPU_BLOCK);
    vec4 data = fetch_from_gpu_cache_1(glyph_address);
    // Select XY or ZW based on glyph index.
    // We use "!= 0" instead of "== 1" here in order to work around a driver
    // bug with equality comparisons on integers.
    vec2 glyph = mix(data.xy, data.zw,
                     bvec2(uint(glyph_index) % GLYPHS_PER_GPU_BLOCK != 0U));

    return Glyph(glyph);
}

struct GlyphResource {
    vec4 uv_rect;
    float layer;
    vec2 offset;
    float scale;
};

GlyphResource fetch_glyph_resource(int address) {
    vec4 data[2] = fetch_from_gpu_cache_2(address);
    return GlyphResource(data[0], data[1].x, data[1].yz, data[1].w);
}

struct TextRun {
    vec4 color;
    vec4 bg_color;
};

TextRun fetch_text_run(int address) {
    vec4 data[2] = fetch_from_gpu_cache_2(address);
    return TextRun(data[0], data[1]);
}

vec2 get_snap_bias(int subpx_dir) {
    // In subpixel mode, the subpixel offset has already been
    // accounted for while rasterizing the glyph. However, we
    // must still round with a subpixel bias rather than rounding
    // to the nearest whole pixel, depending on subpixel direciton.
    switch (subpx_dir) {
        case SUBPX_DIR_NONE:
        default:
            return vec2(0.5);
        case SUBPX_DIR_HORIZONTAL:
            // Glyphs positioned [-0.125, 0.125] get a
            // subpx position of zero. So include that
            // offset in the glyph position to ensure
            // we round to the correct whole position.
            return vec2(0.125, 0.5);
        case SUBPX_DIR_VERTICAL:
            return vec2(0.5, 0.125);
        case SUBPX_DIR_MIXED:
            return vec2(0.125);
    }
}

void main() {
    Instance instance = decode_instance_attributes();
    PrimitiveHeader ph = fetch_prim_header(instance.prim_header_address);
    Transform transform = fetch_transform(ph.transform_id);
    ClipArea clip_area = fetch_clip_area(instance.clip_address);
    PictureTask task = fetch_picture_task(instance.picture_task_address);

    int glyph_index = instance.segment_index;
    int subpx_dir = (instance.flags >> 8) & 0xff;
    int color_mode = instance.flags & 0xff;

    // Note that the reference frame relative offset is stored in the prim local
    // rect size during batching, instead of the actual size of the primitive.
    TextRun text = fetch_text_run(ph.specific_prim_address);
    vec2 text_offset = ph.local_rect.size;

    if (color_mode == COLOR_MODE_FROM_PASS) {
        color_mode = uMode;
    }

    // Note that the unsnapped reference frame relative offset has already
    // been subtracted from the prim local rect origin during batching.
    // It was done this way to avoid pushing both the snapped and the
    // unsnapped offsets to the shader.
    Glyph glyph = fetch_glyph(ph.specific_prim_address, glyph_index);
    glyph.offset += ph.local_rect.p0;

    GlyphResource res = fetch_glyph_resource(instance.resource_address);

    vec2 snap_bias = get_snap_bias(subpx_dir);

    // Glyph space refers to the pixel space used by glyph rasterization during frame
    // building. If a non-identity transform was used, WR_FEATURE_GLYPH_TRANSFORM will
    // be set. Otherwise, regardless of whether the raster space is LOCAL or SCREEN,
    // we ignored the transform during glyph rasterization, and need to snap just using
    // the device pixel scale and the raster scale.
    float raster_scale = float(ph.user_data.x) / 65535.0;

    // Scale in which the glyph is snapped when rasterized.
    float glyph_raster_scale = raster_scale * task.device_pixel_scale;

    // Scale from glyph space to local space.
    float glyph_scale_inv = res.scale / glyph_raster_scale;

    // Glyph raster pixels do not include the impact of the transform. Instead it was
    // replaced with an identity transform during glyph rasterization. As such only the
    // impact of the raster scale (if in local space) and the device pixel scale (for both
    // local and screen space) are included.
    //
    // This implies one or more of the following conditions:
    // - The transform is an identity. In that case, setting WR_FEATURE_GLYPH_TRANSFORM
    //   should have the same output result as not. We just distingush which path to use
    //   based on the transform used during glyph rasterization. (Screen space).
    // - The transform contains an animation. We will imply local raster space in such
    //   cases to avoid constantly rerasterizing the glyphs.
    // - The transform has perspective or does not have a 2d inverse (Screen or local space).
    // - The transform's scale will result in result in very large rasterized glyphs and
    //   we clamped the size. This will imply local raster space.
    vec2 raster_glyph_offset = floor(glyph.offset * glyph_raster_scale + snap_bias) / res.scale;

    // Compute the glyph rect in local space.
    //
    // The transform may be animated, so we don't want to do any snapping here for the
    // text offset to avoid glyphs wiggling. The text offset should have been snapped
    // already for axis aligned transforms excluding any animations during frame building.
    RectWithSize glyph_rect = RectWithSize(glyph_scale_inv * (res.offset + raster_glyph_offset) + text_offset,
                                           glyph_scale_inv * (res.uv_rect.zw - res.uv_rect.xy));

    // Select the corner of the glyph rect that we are processing.
    vec2 local_pos = glyph_rect.p0 + glyph_rect.size * aPosition.xy;

    VertexInfo vi = write_vertex(
        local_pos,
        ph.local_clip_rect,
        ph.z,
        transform,
        task
    );

    vec2 f = (vi.local_pos - glyph_rect.p0) / glyph_rect.size;

    write_clip(vi.world_pos, clip_area, task);

    switch (color_mode) {
        case COLOR_MODE_ALPHA:
        case COLOR_MODE_BITMAP:
            v_color = text.color;
            break;
        case COLOR_MODE_SUBPX_BG_PASS2:
        case COLOR_MODE_SUBPX_DUAL_SOURCE:
            v_color = text.color;
            break;
        case COLOR_MODE_SUBPX_CONST_COLOR:
        case COLOR_MODE_SUBPX_BG_PASS0:
        case COLOR_MODE_COLOR_BITMAP:
            v_color = vec4(text.color.a);
            break;
        case COLOR_MODE_SUBPX_BG_PASS1:
            v_color = vec4(text.color.a) * text.bg_color;
            break;
        default:
            v_color = vec4(1.0);
    }

    vec2 texture_size = vec2(textureSize(sColor0, 0));
    vec2 st0 = res.uv_rect.xy / texture_size;
    vec2 st1 = res.uv_rect.zw / texture_size;

}

#endif // WR_VERTEX_SHADER

#ifdef WR_FRAGMENT_SHADER

void main() {

        write_output(v_color);
}

#endif // WR_FRAGMENT_SHADER

#endif
