set origin_dir [file dirname [info script]]

setws $origin_dir/work_sdk
sdk createhw -name hw_0 -hwspec $origin_dir/src/microblaze/hwspec/system.hdf
sdk createbsp -name bsp_0 -hwproject hw_0 -proc mb_microblaze_0 -os standalone
sdk createapp -name freesrp -hwproject hw_0 -proc mb_microblaze_0 -os standalone -lang C -app {Empty Application} -bsp bsp_0
sdk importsources -name freesrp -path $origin_dir/src/microblaze/src -linker-script
projects -build
