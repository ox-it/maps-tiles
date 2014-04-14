@font: @sans_lt;
@value: [short_name];

// colleges, halls and sites
#university-colleges {
    ::outline {
      line-color: red;
      line-width: 1;
    }  
}

// departments, museums and libraries
#university-departments {
    ::outline {
      line-color: green;
      line-width: 1;
    }    
}

// buildings
#university-buildings {
  [type_name='Site'],
  [type_name='College'],
  [zoom<17] 
  {
    ::polygon {
        polygon-opacity:0.12;
        polygon-fill:@oxfordlightblue;
    }
    ::outline {
      line-color: @oxfordblue;
      line-width: 1;
      line-opacity: 0.12;
    }
  }
  [type_name='Building'],
  [type_name='Library'],
  [type_name='Hall'],
  [type_name='Museum']
  {
    ::polygon {
        polygon-opacity:1;
        polygon-fill:@oxfordlightblue;
    }
    ::outline {
      line-color: @oxfordblue;
      line-width: 1;
      line-opacity: 0.5;
    }
  }
}


#university-labels {
  // only display university labels btween zoom 15 and 18
  [zoom>15][zoom<18] {
      ::labels {
        text-face-name: @font;
        text-name: @value;
        text-fill: @oxfordblue;
        text-size: 10;
        text-halo-fill: fadeout(white, 40%);
        text-halo-radius: 1;
        text-placement: point;
        text-placement-type: simple;  	// Re-position and/or re-size text to avoid overlaps
        text-placements: "N,S,E,W,NE,SE,NW,SW,16,14,12";
        text-max-char-angle-delta: 15;
        text-wrap-width: 25;
        text-min-distance: 2;
      }
    }
}

#curated-shapes {
  [zoom<=16] {
   ::outline {
      line-color: @oxfordblue;
      line-width: 1;
      line-opacity: 0.1;
      line-join: round;
	}
	::shape {
        polygon-opacity: 0.2;
        polygon-fill: desaturate(@oxfordlightblue, 30%);
  	}
  }
}

#curated-labels {
  [zoom<=15] {
  	::labels {
      text-face-name: @font;
      text-name: @value;
      text-fill: black;
      text-size: 15;
      text-halo-fill: fadeout(white, 40%);
      text-halo-radius: 1.5;
      text-placement: point;
      text-placement-type: simple;  	// Re-position and/or re-size text to avoid overlaps
      text-placements: "N,S,E,W,NE,SE,NW,SW,16,14,12";
      text-max-char-angle-delta: 15;
      text-wrap-width: 25;
    }
  }
}
