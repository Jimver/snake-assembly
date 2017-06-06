# PIT constants
RELOAD_VALUE = 59659 # For 20Hz (lowest round freq. due to 16 bit max value) don't modify
LoopPeriod = 1	# Time between gameLoop calls
LoopCount = LoopPeriod * 20 # Don't modify

PIT_CH_0 =	0x40	# IO address for channel 0 of PIT (r/w)
PIT_MC =	0x43	# IO address for mode/command register of PIT (wr only)

# Constants for offsets, so grid is in middle of the screen
X_OFF = 25
Y_OFF = 5

X_OFF_M1 = X_OFF - 1
X_OFF_P1 = X_OFF + 1
Y_OFF_M1 = Y_OFF - 1
Y_OFF_P1 = Y_OFF + 1

GRID = 15

GRID_X = GRID + X_OFF
GRID_Y = GRID + Y_OFF

GRID_M1 = GRID - 1
GRID_P1 = GRID + 1

GRID_X_M1 = GRID_M1 + X_OFF 
GRID_X_P1 = GRID_P1 + X_OFF
GRID_Y_M1 = GRID_M1 + Y_OFF
GRID_Y_P1 = GRID_P1 + Y_OFF

GRID_COR = GRID * 2
GRID_COR_X = GRID_COR + X_OFF
GRID_COR_Y = GRID_COR + Y_OFF

GRID_COR_X_M1 = GRID_COR + X_OFF_M1
GRID_COR_Y_M1 = GRID_COR + Y_OFF_M1
GRID_COR_X_P1 = GRID_COR + X_OFF_P1
GRID_COR_Y_P1 = GRID_COR + Y_OFF_P1

GRID_cells = GRID * GRID

# Snake constants
INIT_SIZE = 2

# Food starting values
FF_X = 2	# first food x
FF_Y = 2	# first food y

# Graphics
W_B = 0x0F	# white on black
B_W = 0xF0	# black on white
G_B = 0x02	# green on black
B_G = 0x20	# black on green
R_B = 0x04	# red on black
B_R = 0x40	# black on red
Y_B = 0x0E	# yellow on black
B_Y = 0xE0	# black on yellow

# Code page 437 codes
GRID_L	= 0xBA	# Left border
GRID_TL = 0xC9	# Top left border
GRID_TR = 0xBB	# Top right border
GRID_T	= 0xCD	# Top border
GRID_BL	= 0xC8	# Bottom left border
GRID_BR	= 0xBC	# Bottom right border
GRID_B	= 0xCD	# Bottom border
GRID_R	= 0xBA	# Right border

FOOD_C	= 0x02	# food code
SN_BODY = 0x6F	# snake body code
SN_HEAD = 0x01	# snake head code 0x40=@
