shader_type spatial;
render_mode world_vertex_coords;

uniform float squish_amount = 5.0;
uniform float flatten_floor = 0.0;

uniform float dropoff_sharpness = 20.0;
uniform float radius = 10.0;

uniform float spread = 4;

void vertex() {
	vec3 scale = vec3(
	    length(MODEL_MATRIX[0].xyz),
	    length(MODEL_MATRIX[1].xyz),
	    length(MODEL_MATRIX[2].xyz)
	);
	
	VERTEX /= scale;
	
	vec3 world_position = NODE_POSITION_WORLD / scale;
	float dist = length(VERTEX - world_position);
	float falloff = dist < radius ? max(1.0 / (dropoff_sharpness * (dist - radius)) + 1.0, 0.0) : 0.0;
	
	float squish_factor = 1.0 /squish_amount;
	
	if(VERTEX.y * squish_factor < flatten_floor * squish_factor + 1.0){
		float y_diff = (exp(squish_factor * (VERTEX.y - flatten_floor) - 1.0) / squish_factor + flatten_floor) / VERTEX.y - 1.0;
		VERTEX.y *= 1.0 + y_diff * falloff;
		
		float x_diff = VERTEX.x - world_position.x;
		float z_diff = VERTEX.z - world_position.z;
		
		
		x_diff *= 1.0 + pow(((flatten_floor * squish_factor + 1.0) - VERTEX.y * squish_factor) * spread, 3) * falloff;
		VERTEX.x = world_position.x + x_diff;
		
		z_diff *= 1.0 + pow(((flatten_floor * squish_factor + 1.0) - VERTEX.y * squish_factor) * spread, 3) * falloff;
		VERTEX.z = world_position.z + z_diff;
	}
	
	VERTEX *= scale;
	
	//VERTEX.y += scale.y / 5.0;
}

uniform vec3 color : source_color;

void fragment(){
	ALBEDO = color;
}
