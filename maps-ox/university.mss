@font: @sans;
@value: [name];

#curated-labels {
  [zoom<=16] {
  	::labels {
      text-face-name: @font;
      text-name: @value;
      text-fill: @oxfordBlue;
      text-size: 15;
      text-halo-fill: fadeout(white, 40%);
      text-halo-radius: 1.75;
      text-min-distance: 5;
      text-placement-type: simple;  	// Re-position and/or re-size text to avoid overlaps
      text-placements: "N,S,E,W,NE,SE,NW,SW,16,14,12";
      text-allow-overlap: true;
      text-wrap-width: 25;
    }
  }
  // hiding Keble Triangle up to zoom 14 as it is too close from ROQ
  [name='Keble Triangle'][zoom<=14] {
  	::labels {
      text-face-name: @font;
      text-name: @value;
      text-fill: @oxfordBlue;
      text-opacity: 0;
    }
  }
  // hiding ROQ up to zoom 13 as it is too close from the Science Area
  [name='Radcliffe Observatory Quarter'][zoom<=13] {
  	::labels {
      text-face-name: @font;
      text-name: @value;
      text-fill: @oxfordBlue;
      text-opacity: 0;
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
  [type_name='Site'][zoom>=16],
  [type_name='College'][zoom>=16],
  [type_name='Hall'][zoom>=16]    
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

#colleges-buildings-labels {
   [zoom>=18] {
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

#colleges-buildings {
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
