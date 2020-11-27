shader_type canvas_item;


uniform mat4 global_transform;

uniform float cutoff =0.99;
uniform float random_blur =0.001;
uniform float blur_amount =2.5;


uniform float dirt_tile_mul =8.0;

uniform sampler2D crack_tiled;
uniform float crack_tile_mul =5.0;

uniform sampler2D noise_tiled;
uniform float noise_tile_mul =30.0;

uniform sampler2D random_noise;
uniform float random_noise_mul =25.0;

uniform sampler2DArray terrain_texture_mix;

uniform float show_hidden=0.0;
varying vec2 worldUV;

float random( vec2 p )
{
    vec2 K1 = vec2(
        23.14069263277926, // e^pi (Gelfond's constant)
         2.665144142690225 // 2^sqrt(2) (Gelfondâ€“Schneider constant)
    );
    return fract( cos( dot(p,K1) ) * 12345.6789 );
}


void vertex() {
	
// VERTEX=(WORLD_MATRIX*vec4(VERTEX,1.0,1.0)).xy;
 //VERTEX  = (global_transform * vec4(VERTEX, 0.0, 1.0)).xy;
// UV=(vec4(UV,1.0,1.0)*inverse(WORLD_MATRIX)).xy;
}

float when_eq(float x, float y) {
  return 1.0 - abs(sign(x - y));
}

float when_neq(float x, float y) {
  return abs(sign(x - y));
}
vec4 getMapColor(sampler2D map_texture,vec2 UV_in, sampler2D SCREEN_TEXTURE_in, vec2 SCREEN_UV_in, float tim)
{
	
	float dirt_number=0.0;
	float water_number=240.0/255.0;
	float magma_number=248.0/255.0;
	float res1_number=8.0/255.0;
	float res2_number=16.0/255.0;
	vec2 tex_size=vec2(textureSize(map_texture,0));
	vec2 inv_size=1.0/tex_size;
	float aspect = inv_size.y/inv_size.x;
	//UV_in=(vec2(ivec2(UV_in*8192.0))/8192.0);
	vec4 real_col=texture(map_texture, UV_in);
	float healthy=real_col.r;
	float is_hidden=clamp(float(real_col.b*1.0),0.0,1.0)*show_hidden;
	vec2 UV_in_scaled=UV_in*tex_size*0.001;
	vec2 random_blur_scaled=random_blur*inv_size*1000.0;
	
	//healthy=0.8;
	//vec4 col=textureLod(TEXTURE, UV,blur_amount + random_blur* texture(random_noise,UV*random_noise_mul).r);
	vec4 col=textureLod(map_texture, UV_in+ random_blur_scaled* (texture(random_noise,UV_in_scaled*random_noise_mul).r-0.5),blur_amount);
	vec4 col_res=textureLod(map_texture, UV_in+17.0* random_blur_scaled*(texture(random_noise,UV_in_scaled*vec2(4.0)).rg-0.5),0.0);
	col.a*=1.0-is_hidden;
	col_res.a*=1.0-is_hidden;
	real_col.a*=1.0-is_hidden;
	//col.a=is_hidden;
	
	
	float is_non_trans=when_eq(col_res.a,1.0);

	float resource_type=col_res.g*is_non_trans+(1.0-is_non_trans)*real_col.g;
	vec4 outCOLOR=texture(terrain_texture_mix,vec3(UV_in_scaled*dirt_tile_mul,(resource_type*255.0)));
	//Po co to na dole bylo??
	outCOLOR.a=clamp((16.0-((resource_type*255.0+0.0)*0.125)),0.0,1.0);
	outCOLOR.a-=clamp(float(real_col.b*2586.0),0.0,1.0)*show_hidden;


	float is_water_for=0.0;
	float water_check=6.0;
	vec4 water_check1 =texture(map_texture, UV_in+vec2(water_check,water_check)/tex_size);
	vec4 water_check2 =texture(map_texture, UV_in+vec2(-water_check,-water_check)/tex_size);
	vec4 water_check3 =texture(map_texture, UV_in+vec2(water_check,-water_check)/tex_size);
	vec4 water_check4 =texture(map_texture, UV_in+vec2(-water_check,water_check)/tex_size);

	is_water_for+=float(water_check1.g==water_number);
	is_water_for+=float(water_check2.g==water_number);
	is_water_for+=float(water_check3.g==water_number);
	is_water_for+=float(water_check4.g==water_number);


	//is_water_for=clamp(is_water_for,0.0,100.0);
	float is_water_for_normalized=is_water_for*0.0025;
	float is_water_for_clamped=clamp(is_water_for,0.0,1.0);
	float is_water=float(col_res.g==water_number);
	
	//dirt=col_res;
	//x coord multipled because of aspect ratio
	vec4 crack=texture(crack_tiled, vec2(UV_in_scaled*crack_tile_mul)); 
	vec4 crack_small=texture(crack_tiled, vec2(UV_in_scaled*crack_tile_mul)*3.0); 
	
	if(noise_tile_mul>0.0)
	{
		vec4 noise=texture(noise_tiled, UV_in_scaled*noise_tile_mul);
		outCOLOR.rgb*=0.4+noise.rgb; // darker patches
	}
	//commented section is to disable cracks on some material
	outCOLOR.rgb-=col.a*(((1.0-crack.rgb*1.0)*clamp(1.0-(healthy*healthy*healthy),0.0,1.0)+(1.0-crack_small.rgb*1.0)*clamp(1.0-(healthy*healthy*healthy/*+is_res1*/),0.0,1.0))); //crack damaged terrain

	float is_water_border=min(((1.0-is_non_trans)*is_water_for_clamped)+is_water,1.0);
	if(col.a<cutoff)
	{
		//outCOLOR.rgb+=(is_water_for_clamped*col.a)*vec3(0.5,0.5,1.0);
		outCOLOR.rgb-=(cutoff-col.a);
		outCOLOR.a=(1.0-is_water_border)*col.a/cutoff;// = vec4(vec3(dirt.rgb)-0.4,col.a);
		outCOLOR.rgb-=(is_water_border)*vec3(0.8,0.0,0.0);
		outCOLOR.a+=(is_water_border)*0.1*col.a/cutoff;
		//outCOLOR-=is_water*vec4(0.0,0.0,1.0,0.1)*1.0;

	}
	
	//Shadow between different resources
	float same=0.0;

		
	vec2 check=6.0*inv_size;
	float alf=0.0;
	vec4 col_res2=textureLod(map_texture, UV_in+check+17.0* random_blur_scaled*(texture(random_noise,UV_in_scaled*vec2(4.0)).rg-0.5),0.0);
	
	//	if(col_res.g==col_res2.g )same+=1;
	//if(water_check4.a!=1.0 || col_res2.a!=1.0)alf+=10.5;
	same+=when_eq(col_res.g,col_res2.g) ;
	alf+=(when_neq(water_check1.a,1.0) +when_neq(col_res2.a,1.0))*10.0;

	col_res2=textureLod(map_texture, UV_in+check*vec2(1,-1)+17.0* random_blur_scaled*(texture(random_noise,UV_in_scaled*vec2(4.0)).rg-0.5),0.0);
	same+=when_eq(col_res.g,col_res2.g) ;
	alf+=(when_neq(water_check2.a,1.0) +when_neq(col_res2.a,1.0))*10.0;

	col_res2=textureLod(map_texture, UV_in+check*vec2(-1,-1)+17.0* random_blur_scaled*(texture(random_noise,UV_in_scaled*vec2(4.0)).rg-0.5),0.0);
	same+=when_eq(col_res.g,col_res2.g);
	alf+=(when_neq(water_check3.a,1.0) +when_neq(col_res2.a,1.0))*10.0;

	col_res2=textureLod(map_texture, UV_in+check*vec2(-1,1)+17.0* random_blur_scaled*(texture(random_noise,UV_in_scaled*vec2(4.0)).rg-0.5),0.0);
	same+=when_eq(col_res.g,col_res2.g);
	alf+=(when_neq(water_check4.a,1.0) +when_neq(col_res2.a,1.0))*10.0;
	
	outCOLOR.rgb*=pow(clamp(0.25*same+alf,0.5,1.0),0.5);

	return outCOLOR;
}

vec4 getMapColor2(sampler2D map_texture,vec2 UV_in, sampler2D SCREEN_TEXTURE_in, vec2 SCREEN_UV_in, float tim)
{
	float resource_type=0.0;
	vec4 outCOLOR=texture(terrain_texture_mix,vec3(UV_in*dirt_tile_mul,resource_type));
	
	return outCOLOR;
}
void fragment()
{		

	
	
	
	
	COLOR=getMapColor(TEXTURE,UV,SCREEN_TEXTURE,SCREEN_UV,TIME);
	//COLOR=texture(TEXTURE,UV);
	
	//COLOR=vec4(vec3(textureLod(map_texture,UV,blur_amount).r),1.0) ;
}