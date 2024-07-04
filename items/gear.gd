class_name Gear extends Item
#Cyberpunk RED Rules: Armor (pg.96)
#Armor must be purchased individually for either the head or body locations. 
#SP gained by armor does not "stack;" Only your highest source of SP in a location determines your SP for that location. All your worn armor in a location is ablated (SP lowered by one) simultaneously whenever you take damage.
const ARMOR_TABLE = { 
	"Leather"            : { sp =  4, penal = 0, cost =   20 }, 
	"Kevlar"             : { sp =  7, penal = 0, cost =   50 }, 
	"Light Armorjack"    : { sp = 11, penal = 0, cost =  100 }, 
	"Bodyweight Suit"    : { sp = 11, penal = 0, cost = 1000 }, 
	"Medium Armorjack"   : { sp = 12, penal = 2, cost =  100 }, 
	"Heavy Armorjack"    : { sp = 13, penal = 2, cost =  500 }, 
	"Flak"               : { sp = 15, penal = 4, cost =  500 }, 
	"Metal Gear"         : { sp = 18, penal = 4, cost = 5000 }, 
	"Bulletproof Shield" : { sp = 10, penal = 0, cost =  100 }
	}
# Penalties only affect REF, DEX and MOVE by the same number
## (!) Bulletproof Shield's SP should be treated as HEALTH POINTS and are reduced by damage
enum ArmorType { 
	Leather, 
	Kevlar, 
	LightArmorjack, 
	BodyweightSuit, 
	MediumArmorjack, 
	HeavyArmorjack, 
	Flak, 
	MetalGear, 
	Shield 
	}
@export var armor_type:ArmorType
var base_sp:int  #Stopping Power
var sp:int:
	set(value):
		sp = value
		sp = clamp(sp, 0, base_sp)
var penalty:int  #How much does interfere with ability to move and respond
var hp:int


func _ready() -> void:
	var armor_data = ARMOR_TABLE[ARMOR_TABLE.keys()[armor_type]]
	
	base_sp = armor_data.sp
	sp = base_sp
	
	penalty = armor_data.penal
	cost = armor_data.cost
