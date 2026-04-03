# ─────────────────────────────────────────────────────
# Full 16-pair RO Placement TCL
# For PARALLEL puf_16bit (genvar generate version)
# ─────────────────────────────────────────────────────

package require ::quartus::project
project_open puf_auth

puts "Placing 16 RO pairs across chip..."

# Format: BIT[i] = generate block instance name
# Node path: PUF_GEN|BIT[i]|inst|n0a etc.

# X,Y coordinates spread across EP4CE115 fabric
# EP4CE115 is roughly 60 cols x 60 rows of LABs
# Each LAB has 16 LEs (N0 to N15)
# Keep RO_A in N0-N4, RO_B in N5-N9 of SAME LAB

set placements {
    {0  10 50}
    {1  15 45}
    {2  20 40}
    {3  25 50}
    {4  30 45}
    {5  35 40}
    {6  40 50}
    {7  45 45}
    {8  10 30}
    {9  15 25}
    {10 20 30}
    {11 25 25}
    {12 30 30}
    {13 35 25}
    {14 40 30}
    {15 45 25}
}

foreach item $placements {
    set i [lindex $item 0]
    set x [lindex $item 1]
    set y [lindex $item 2]

    set base "PUF_GEN|BIT\[$i\]|inst"

    # RO_A inverter chain → N0 to N4
    set_location_assignment LCCOMB_X${x}_Y${y}_N0 -to "${base}|n0a"
    set_location_assignment LCCOMB_X${x}_Y${y}_N1 -to "${base}|n1a"
    set_location_assignment LCCOMB_X${x}_Y${y}_N2 -to "${base}|n2a"
    set_location_assignment LCCOMB_X${x}_Y${y}_N3 -to "${base}|n3a"
    set_location_assignment LCCOMB_X${x}_Y${y}_N4 -to "${base}|n4a"

    # RO_B inverter chain → N5 to N9 (same LAB, adjacent LEs)
    set_location_assignment LCCOMB_X${x}_Y${y}_N5  -to "${base}|n0b"
    set_location_assignment LCCOMB_X${x}_Y${y}_N6  -to "${base}|n1b"
    set_location_assignment LCCOMB_X${x}_Y${y}_N7  -to "${base}|n2b"
    set_location_assignment LCCOMB_X${x}_Y${y}_N8  -to "${base}|n3b"
    set_location_assignment LCCOMB_X${x}_Y${y}_N9  -to "${base}|n4b"

    puts "  Bit $i placed at X=${x} Y=${y}"
}

project_close
puts ""
puts "All 16 pairs placed successfully!"
puts "Now run: Processing -> Start Compilation"


