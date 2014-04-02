@font: @sans_lt;
@value: [short_name];

#university-shapes {
  [type_name = "College"],
  [type_name = "Hall"],
  [type_name = "Department"],
  [type_name = "Museum"] {
    ::polygon {
        polygon-opacity:0.1;
        polygon-fill:@oxfordlightblue;
    }
    ::outline {
      line-color: @oxfordblue;
      line-width: 1;
      line-opacity: 0.12;
    }
      
  
    [zoom>=16] {
      ::polygon {
        polygon-opacity: 0.17;
      }
      ::outline {
        line-opacity: 0.1;
      }
    }
    [zoom>=18] {
      ::polygon {
        polygon-opacity: 0.2;
      }
      ::outline {
        line-opacity: 0.1;
        }
     }
  }
}

#university-labels {
  // only display university labels at zoom 15
  [zoom>15][zoom<18] {
    [type_name = "College"],
    [type_name = "Department"],
    [type_name = "Hall"],
    [type_name = "Museum"] {
      ::labels {
        text-face-name: @font;
        text-name: @value;
        text-fill: @oxfordblue;
        text-size: 10;
        text-halo-fill: fadeout(white, 40%);
        text-halo-radius: 1.5;
        text-placement: point;
        text-placement-type: simple;  	// Re-position and/or re-size text to avoid overlaps
        text-placements: "N,S,E,W,NE,SE,NW,SW,16,14,12";
        text-max-char-angle-delta: 15;
        text-wrap-width: 25;
        text-min-distance: 2;
      }
    }
  }
}

#curated-shapes {
  [zoom<=20] {
   ::outline {
      line-color: @oxfordblue;
      line-width: 1;
      line-opacity: 0.1;
      line-join: round;
	}
	::shape {
        polygon-opacity: 0.4;
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
