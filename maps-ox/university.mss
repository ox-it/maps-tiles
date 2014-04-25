@font: @sans;
@value: [short_name];

#curated-labels {
  [zoom<=16] {
  	::labels {
      text-face-name: @font;
      text-name: @value;
      text-fill: @oxfordBlue;
      text-size: 16;
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

#university-buildings-labels {
   [zoom>16] {
      ::labels {
        text-face-name: @font;
        text-name: @value;
        text-fill: @oxfordDarkBlue;
        text-size: 11;
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
#university-colleges-labels {
  [type_name='Site'][zoom>16],
  [type_name='College'],
  [type_name='Hall']    
 {
      ::labels {
        text-face-name: @font;
        text-name: @value;
        text-fill: @oxfordDarkBlue;
        text-size: 14;
        text-halo-fill: fadeout(white, 40%);
        text-halo-radius: 1;
        text-placement: point;
        text-placement-type: simple;  	// Re-position and/or re-size text to avoid overlaps
        text-placements: "N,S,E,W,NE,SE,NW,SW,16,14,12";
        text-max-char-angle-delta: 15;
        text-wrap-width: 25;
        text-min-distance: 2;
        [zoom>=17] {
          text-fill: lighten(@oxfordDarkBlue, 10%);
        }
      }
    }
}

// buildings
#university-buildings {
  ::polygon {
      polygon-opacity: 1;
      polygon-fill: @universityBuilding;
  }
  ::outline {
    line-color: @universityBuildingOutline;
    line-width: 1;
  }
  [zoom < 17] {
    ::outline {
      line-width: 0.5;
    }
  }  
}

#curated-shapes {
  [zoom<=16] {
   ::outline {
      line-color: @universitySiteOutline;
      line-width: 1;
      line-opacity: 1;
	}
	::shape {
        polygon-opacity: 0.2;
        polygon-fill: @universitySite;
  	}
  }
}

// colleges, halls and sites
#university-colleges {
  [type_name='Site'][zoom>16],
  [type_name='College'],
  [type_name='Hall']    
  {
    ::polygon {
      polygon-fill:@universitySite;
      polygon-opacity: 0.2;
    }
    ::outline {
      line-color: @universitySiteOutline;
      line-width: 1;
      line-opacity: 1;
    }
    [zoom < 17] {
      ::outline {
        line-width: 0.5;
      }
    }
  }
}
