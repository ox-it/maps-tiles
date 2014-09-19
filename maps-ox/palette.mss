/* ****************************************************************** */
/* OSM BRIGHT for Imposm                                              */
/* ****************************************************************** */

/* For basic style customization you can simply edit the colors and
 * fonts defined in this file. For more detailed / advanced
 * adjustments explore the other files.
 *
 * GENERAL NOTES
 *xw
 * There is a slight performance cost in rendering line-caps.  An
 * effort has been made to restrict line-cap definitions to styles
 * where the results will be visible (lines at least 2 pixels thick).
 */

/* ================================================================== */
/* FONTS
/* ================================================================== */

/* directory to load fonts from in addition to the system directories */
Map {
  font-directory: url(./fonts);
  buffer-size: 256;
}

/* set up font sets for various weights and styles */
@sans_lt:           "Open Sans Regular","DejaVu Sans Book","unifont Medium";
@sans_lt_italic:    "Open Sans Italic","DejaVu Sans Italic","unifont Medium";
@sans:              "Open Sans Semibold","DejaVu Sans Book","unifont Medium";
@sans_italic:       "Open Sans Semibold Italic","DejaVu Sans Italic","unifont Medium";
@sans_bold:         "Open Sans Bold","DejaVu Sans Bold","unifont Medium";
@sans_bold_italic:  "Open Sans Bold Italic","DejaVu Sans Bold Italic","unifont Medium";

/* Some fonts are larger or smaller than others. Use this variable to
   globally increase or decrease the font sizes. */
/* Note this is only implemented for certain things so far */
@text_adjust: 0;

/* ================================================================== */
/* LANDUSE & LANDCOVER COLORS
/* ================================================================== */

@land:              desaturate(#FCFBea, 5%);
@water:             desaturate(#C4DFfa, 5%);
@grass:             desaturate(#dae3c3, 10%);
@beach:             desaturate(#FFEEca, 10%);
@park:              desaturate(#D3ecc0, 10%);
@cemetery:          desaturate(#D6DEd5, 10%);
@wooded:            desaturate(#b7D0a5, 5%);
@agriculture:       desaturate(#F2E8ba, 5%);

@building:          #E0dad5;
@hospital:          desaturate(rgb(229,198,205), 10%);
@school:            desaturate(#FFF5cC, 10%);
@sports:            desaturate(#a9dab0, 15%);

@residential:       @land * 0.98;
@commercial:        @land * 0.97;
@industrial:        @land * 0.96;
@parking:           #EEE;

/* ================================================================== */
/* ROAD COLORS
/* ================================================================== */

/* For each class of road there are three color variables:
 * - line: for lower zoomlevels when the road is represented by a
 *         single solid line.
 * - case: for higher zoomlevels, this color is for the road's
 *         casing (outline).
 * - fill: for higher zoomlevels, this color is for the road's
 *         inner fill (inline).
 */

@motorway_line:     #E65C5C;
@motorway_fill:     lighten(@motorway_line,20%);
@motorway_case:     @motorway_line * 0.9;

@trunk_line:        #E68A5C;
@trunk_fill:        lighten(@trunk_line,20%);
@trunk_case:        @trunk_line * 0.9;

@primary_line:      #FFC859;
@primary_fill:      lighten(@primary_line,20%);
@primary_case:      @primary_line * 0.9;

@secondary_line:    #FFE873;
@secondary_fill:    lighten(@secondary_line,20%);
@secondary_case:    @secondary_line * 0.9;

@standard_line:     @land * 0.85;
@standard_fill:     #fff;
@standard_case:     @land * 0.9;

@pedestrian_line:   @standard_line;
@pedestrian_fill:   #FAFAF5;
@pedestrian_case:   @land;

@cycle_line:        @standard_line;
@cycle_fill:        #FAFAF5;
@cycle_case:        @land;

@rail_line:         #999;
@rail_fill:         #fff;
@rail_case:         @land;

@aeroway:           #ddd;

/* ================================================================== */
/* BOUNDARY COLORS
/* ================================================================== */

@admin_2:           #324;

/* ================================================================== */
/* LABEL COLORS
/* ================================================================== */

/* We set up a default halo color for places so you can edit them all
   at once or override each individually. */
@place_halo:        fadeout(#fff,34%);

@country_text:      #435;
@country_halo:      @place_halo;

@state_text:        #546;
@state_halo:        @place_halo;

@city_text:         #444;
@city_halo:         @place_halo;

@town_text:         #666;
@town_halo:         @place_halo;

@poi_text:          #888;

@road_text:         #777;
@road_halo:         #fff;

@other_text:        #888;
@other_halo:        @place_halo;

@locality_text:     #aaa;
@locality_halo:     @land;

/* Also used for other small places: hamlets, suburbs, localities */
@village_text:      #888;
@village_halo:      @place_halo;

/* ****************************************************************** */

/* ================================================================== */
/* OXFORD COLORS
/* ================================================================== */

@pantone282: rgb(0, 33, 71);
@pantone279: rgb(72, 145, 220);
@pantone291: rgb(159, 206, 235);
@pantone5405: rgb(68, 104, 125);
@pantone549: rgb(95, 155, 175);
@pantone551: rgb(161, 196, 208);
@pantone562: rgb(0, 119, 112);
@pantone624: rgb(123, 162, 150);
@pantone559: rgb(188, 210, 195);
@pantone576: rgb(105, 145, 59);
@pantone578: rgb(185, 207, 150);
@pantone580: rgb(206, 219, 175);
@pantone583: rgb(170, 179, 0);
@pantone585: rgb(219, 222, 114);
@pantone587: rgb(227, 229, 151);
@pantone7412: rgb(207, 122, 48);
@pantone129: rgb(245, 207, 71);
@pantone127: rgb(243, 222, 116);
@pantone202: rgb(135, 36, 52);
@pantone200: rgb(190, 15, 52);
@pantone196: rgb(167, 157, 150);
@pantoneWarmGray6: rgb(167, 157, 150);
@pantoneWarmGray3: rgb(199, 194, 198);
@pantoneWarmGray1: rgb(224, 222, 217);

// Near approximations (CMYK colours)
@pantone872: #b2965b;
@pantone877: #a7a8ac;

// Colours
@highlightBlue: @pantone279;
@oxfordLightBlue: @pantone551;
@oxfordMediumBlue: @pantone549;
@oxfordDarkBlue: @pantone5405;
@oxfordBlue: @pantone282;
@oxfordGold: @pantone872;

//Types
@universityBuilding: darken(@pantoneWarmGray3, 6%
  );
@universityBuildingOutline: @pantoneWarmGray6;
@universitySite:@oxfordLightBlue;
@universitySiteOutline:@oxfordMediumBlue;
@collegeBuilding: rgb(210, 194, 181);
@collegeBuildingOutline: @pantoneWarmGray6;

