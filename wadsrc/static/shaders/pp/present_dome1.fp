
layout(location=0) in vec2 TexCoord;
layout(location=0) out vec4 FragColor;

layout(binding=0) uniform sampler2D tex1;
layout(binding=1) uniform sampler2D tex2;
layout(binding=2) uniform sampler2D tex3;
layout(binding=3) uniform sampler2D tex4;
layout(binding=4) uniform sampler2D tex5;
layout(binding=5) uniform sampler2D tex6;

layout(binding=6) uniform sampler3D tex7;

vec4 ApplyGamma(vec4 c)
{
	vec3 val = c.rgb * Contrast - (Contrast - 1.0) * 0.5;
	val += Brightness * 0.5;
	val = pow(max(val, vec3(0.0)), vec3(InvGamma));
	return vec4(val, c.a);
}

















vec2 map( vec3 p )
{
    vec2 d2 = vec2( p.y+1.0, 2.0 );

	float r = 1.0;
	float f = smoothstep( 0.0, 0.5, sin(3.0+Time) );
	float d = 0.5 + 0.5*sin( 4.0*p.x + 0.13*Time)*
		                sin( 4.0*p.y + 0.11*Time)*
		                sin( 4.0*p.z + 0.17*Time);
    r += f*0.4*pow(d,4.0);//*(0.5-0.5*p.y);
    vec2 d1 = vec2( length(p) - r, 1.0 );

	return d1;
}


vec4 sphereColor( in vec3 pos, in vec3 nor )
{
	vec2 uv = vec2( atan( nor.x, nor.z ), acos(nor.y) );
    vec3 col = vec3(1,0,1);
    float ao = clamp( 0.75 + 0.25*nor.y, 0.0, 1.0 );
    return vec4( col, ao );
}









#define PI 3.14159265358979323846264338327

// from https://www.shadertoy.com/view/XllGW4

mat2 Rot2(float a ) {
    float c = cos( a );
    float s = sin( a );
    return mat2( c, -s, s, c );
}

mat4 Rot4X(float a ) {
    float c = cos( a );
    float s = sin( a );
    return mat4( 1, 0, 0, 0,
                 0, c,-s, 0,
                 0, s, c, 0,
                 0, 0, 0, 1 );
}

mat4 Rot4Y(float a ) {
    float c = cos( a );
    float s = sin( a );
    return mat4( c, 0, s, 0,
                 0, 1, 0, 0,
                -s, 0, c, 0,
                 0, 0, 0, 1 );
}

mat4 Rot4Z(float a ) {
    float c = cos( a );
    float s = sin( a );
    return mat4(
        c,-s, 0, 0,
        s, c, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
     );
}

// from: https://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-sphere-intersection.html

float uglyRaySphereIntersect(vec3 rayorigin, vec3 raydirection, vec3 center, float radius) {

    vec3 L = center - rayorigin;

    float tca = dot(L, raydirection);
    // if (tca < 0) return false;

    float d2 = dot(L, L) - tca * tca;

    if (d2 > radius) {
        return -1.0;
    }

    float thc = sqrt(radius - d2);
    float t0 = tca - thc;
    // float t1 = tca + thc;

    return t0;
}

// from https://paulbourke.net/papers/cgat09/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/UVScale.xy;
    vec2 aspect = vec2(UVScale.x/UVScale.y, 1.0);
    vec2 nuv = ((uv.xy-0.5) * 2.26 * aspect) + 0.0;

    vec3 ray = vec3(nuv, 1.0);
    float len = length(ray);

    ray = normalize(ray);

    float R = 1.0;
    float Ex = 0.0;


    vec4 P0 = vec4(ray, 0);// vec4(P0x, P0y, P0z, 0.0);

    float rr = (PI/2.0) * (nuv.x*nuv.x + nuv.y*nuv.y) / 2.0;

    vec4 ret = vec4(0,0,0,1);

    vec3 origin = vec3(0, 0, 1.33333);//0.707 * 3.14);

    float T0 = uglyRaySphereIntersect(origin, ray, vec3(0.0,0.0,0.0), 1.0);

    vec3 TP = origin + T0 * ray;
    vec3 N = normalize(-TP);

    P0 = vec4(N,0);

    // mat4 m1 = Rot4Z( 0.0 * 0.03 );
    // mat4 m2 = Rot4Y( 0.0 * 0.4 );
    mat4 m3 = Rot4X( Pitch / 180.0 * PI );
    // P0 *= m1;
    // P0 *= m2;
    P0 *= m3;

    float P0xa = abs(P0.x);
    float P0ya = abs(P0.y);
    float P0za = abs(P0.z);

    // tex1 = {{-0.1f, 1.f, 0, -90},
    // tex2 =  {-0.1f, 1.f, 0, 90},
    // tex3 =  {-0.1f, 1.f, -90, 0},
    // tex4 =  {-0.1f, 1.f, 0, 0},
    // tex5 =  {-0.1f, 1.f, 0, -180},
    // tex6 =  {-0.1f, 1.f, 0, 0},

    if (P0xa > P0ya && P0xa > P0za) {

        vec2 side = vec2(P0.z, P0.y);
        side.x /= P0xa;
        side.y /= P0xa;
        side = side / 2.0 + 0.5;

        if (P0.x > 0.0) {
            side.x = 1.0 - side.x;
            ret += texture(tex1, side);
        } else {
            ret += texture(tex2, side);
        }

        // ret += vec4(0.1, 0.0, 0.0, 0.0);

    } else if (P0ya > P0xa && P0ya > P0za) {

        vec2 side = vec2(P0.x, P0.z);
        side.x /= P0ya;
        side.y /= P0ya;
        side = side / 2.0 + 0.5;

        if (P0.y > 0.0) {
            side.y = 1.0 - side.y;
            ret += texture(tex4, side);
        } else {
            ret += texture(tex3, side);
        }

        // ret += vec4(0.0, 0.1, 0.0, 0.0);

    } else {

        vec2 side = vec2(P0.x, P0.y);
        side.x /= P0za;
        side.y /= P0za;
        side = side / 2.0 + 0.5;

        if (P0.z > 0.0) {
            ret += texture(tex6, side);
        } else {
            side.x = 1.0 - side.x;
            ret += texture(tex5, side);
        }

        // ret += vec4(0.0, 0.0, 0.1, 0.0);
    }

    if (rr > 1.0) {
        ret *= 0.5;
    }

    fragColor = ret;

}























void main()
{
	int thisVerticalPixel = int(gl_FragCoord.y); // Bottom row is typically the right eye, when WindowHeight is even
	int thisHorizontalPixel = int(gl_FragCoord.x); // column

	bool isLeftEye = (thisVerticalPixel // because we want to alternate eye view on each row
			+ thisHorizontalPixel // and each column
			+ WindowPositionParity // because the window might not be aligned to the screen
		) % 2 == 0;

	vec4 inputColor = vec4(0,0,0,1);

	vec4 tmpColor;

	mainImage(tmpColor, TexCoord);

	inputColor += tmpColor;

	FragColor = ApplyGamma(inputColor);
}
