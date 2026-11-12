/*
 * This file is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
  parameter object for one custom OSD item (CST1..CST12):
  bitmask of Lua values PARAM1..PARAM8 to show, and screen position
 */

#include "AP_OSD.h"

#if OSD_ENABLED || OSD_PARAM_ENABLED

const AP_Param::GroupInfo AP_OSD_CustomSetting::var_info[] = {
    // @Param: _MASK
    // @DisplayName: Custom item values
    // @Description: Bitmask of custom values (set by Lua) shown in this item, one per line starting at _Y. 0 disables the item
    // @Bitmask: 0:PARAM1,1:PARAM2,2:PARAM3,3:PARAM4,4:PARAM5,5:PARAM6,6:PARAM7,7:PARAM8
    // @User: Standard
    AP_GROUPINFO("_MASK", 1, AP_OSD_CustomSetting, mask, 0),

    // @Param: _X
    // @DisplayName: X position
    // @Description: Horizontal position on screen
    // @Range: 0 59
    // @User: Standard
    AP_GROUPINFO("_X", 2, AP_OSD_CustomSetting, xpos, 0),

    // @Param: _Y
    // @DisplayName: Y position
    // @Description: Vertical position on screen of the first value; next values go below
    // @Range: 0 21
    // @User: Standard
    AP_GROUPINFO("_Y", 3, AP_OSD_CustomSetting, ypos, 0),

    AP_GROUPEND
};

AP_OSD_CustomSetting::AP_OSD_CustomSetting()
{
    AP_Param::setup_object_defaults(this, var_info);
}

#endif // OSD_ENABLED || OSD_PARAM_ENABLED
