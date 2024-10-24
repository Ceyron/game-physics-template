struct VertexOutput {
        @builtin(position) position: vec4f,
        @location(0) uv: vec2f,
        @location(1) cmapOffset: f32,
      }

struct ImageAttributes {
    @location(0) x: f32,
    @location(1) y: f32,
    @location(2) sx: f32,
    @location(3) sy: f32,
    @location(4) offset: i32,
    @location(5) width: i32,
    @location(6) height: i32,
    @location(7) cmapOffset: f32,

}

@vertex
fn vs_main(@builtin(vertex_index) VertexIndex: u32, imageAttributes: ImageAttributes) -> VertexOutput {
    var pos = array(
        vec2(1.0, 1.0),
        vec2(-1.0, -1.0),
        vec2(1.0, -1.0),
        vec2(1.0, 1.0),
        vec2(-1.0, 1.0),
        vec2(-1.0, -1.0),
    );

    var uv = array(
        vec2(1.0, 0.0),
        vec2(0.0, 1.0),
        vec2(1.0, 1.0),
        vec2(1.0, 0.0),
        vec2(0.0, 0.0),
        vec2(0.0, 1.0),
    );

    let size = vec2f(imageAttributes.sx, imageAttributes.sy);
    let position = vec2f(imageAttributes.x, imageAttributes.y);
    var output: VertexOutput;
    output.position = vec4f(pos[VertexIndex] * size + position, 0.0, 1.0);
    output.uv = uv[VertexIndex];

    output.uv.x *= f32(imageAttributes.width);
    output.uv.y *= f32(imageAttributes.height);

    output.cmapOffset = imageAttributes.cmapOffset;

    return output;
}

@group(0) @binding(0) var texture: texture_2d<f32>;
@group(0) @binding(1) var cmapTexture: texture_2d<f32>;
@group(0) @binding(2) var cmapSampler: sampler;


@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let value = textureLoad(texture, vec2i(in.uv), 0).r;
    let color = textureSample(cmapTexture, cmapSampler, vec2f(value, in.cmapOffset)).rgb;
    let corrected = vec4f(pow(color, vec3f(2.2)), 1.0);
    return corrected;
}