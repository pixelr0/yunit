/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtTest 1.0
import Unity.Test 0.1 as UT
import ".."
import "../../../Panel"
import Unity.Indicators 0.1 as Indicators

/*
  This tests the IndicatorRow component by using a fake model to stage data in the indicators
  A view will show with indicators at the top, as does in the shell.
*/
Item {
    id: rootItem
    width: units.gu(40)
    height: units.gu(60)

    function init_test()
    {
        indicatorRow.overviewActive = false;
        indicatorRow.state = "initial";
        indicatorRow.currentItem = null;
    }

    PanelBackground {
        anchors.fill: indicatorRow
    }

    IndicatorRow {
        id: indicatorRow
        anchors {
            left: parent.left
            right: parent.right
        }

        indicatorsModel: indicatorModel
    }

    Indicators.IndicatorsModel {
        id: indicatorModel
        Component.onCompleted: load()
    }

    UT.UnityTestCase {
        name: "IndicatorRow"
        when: windowShown

        function test_set_current_item() {
            init_test();
            indicatorRow.setItem(0);
            compare(indicatorRow.indicatorsModel.get(indicatorRow.currentItemIndex).title, "Menu1", "Incorrect item at position 0");

            indicatorRow.setItem(1);
            compare(indicatorRow.indicatorsModel.get(indicatorRow.currentItemIndex).title, "Menu2", "Incorrect item at position 1");

            indicatorRow.setItem(2);
            compare(indicatorRow.indicatorsModel.get(indicatorRow.currentItemIndex).title, "Menu3", "Incorrect item at position 2");
        }
    }

    UT.UnityTestCase {
        name: "IndicatorRow_IconPosition"
        when: windowShown

        function get_indicator_item_at(index) {
            return findChild(indicatorRow, "rowRepeater").itemAt(index);
        }

        function test_current_item_commit() {
            init_test();

            indicatorRow.setItem(1);
            indicatorRow.state = "commit";
            tryCompare(get_indicator_item_at(0), "y", -indicatorRow.height);
            tryCompare(get_indicator_item_at(1), "y", 0);
            tryCompare(get_indicator_item_at(2), "y", -indicatorRow.height);
            tryCompare(get_indicator_item_at(3), "y", -indicatorRow.height);
            tryCompare(get_indicator_item_at(4), "y", -indicatorRow.height);

        }
    }

    UT.UnityTestCase {
        name: "IndicatorRow_Highlight"
        when: windowShown

        function get_indicator_item_at(index) {
            return findChild(indicatorRow, "rowRepeater").itemAt(index);
        }

        function test_intial_state() {
            init_test();

            indicatorRow.state = "initial";
            indicatorRow.setItem(0);

            compare(indicatorRow.currentItem.highlighted, false, "Indicator should not highlight when in initial state");
            compare(get_indicator_item_at(1).highlighted, false, "Other indicators should not highlight when in initial state");
            compare(get_indicator_item_at(2).highlighted, false, "Other indicators should not highlight when in initial state");
            compare(get_indicator_item_at(3).highlighted, false, "Other indicators should not highlight when in initial state");
            compare(get_indicator_item_at(4).highlighted, false, "Other indicators should not highlight when in initial state");
        }

        function test_hint_state() {
            init_test();

            indicatorRow.state = "hint";
            indicatorRow.setItem(0);

            compare(indicatorRow.currentItem.highlighted, false, "Indicator should not highlight when in hint state");
            compare(get_indicator_item_at(1).highlighted, false, "Other indicators should not highlight when in hint state");
            compare(get_indicator_item_at(2).highlighted, false, "Other indicators should not highlight when in hint state");
            compare(get_indicator_item_at(3).highlighted, false, "Other indicators should not highlight when in hint state");
            compare(get_indicator_item_at(4).highlighted, false, "Other indicators should not highlight when in hint state");
        }

        function test_revealed_state() {
            init_test();

            indicatorRow.state = "reveal";
            indicatorRow.setItem(0);

            compare(indicatorRow.currentItem.highlighted, true, "Indicator should highlight when in reveal state");
            compare(get_indicator_item_at(1).highlighted, false, "Other indicators should not highlight when in commit state");
            compare(get_indicator_item_at(2).highlighted, false, "Other indicators should not highlight when in commit state");
            compare(get_indicator_item_at(3).highlighted, false, "Other indicators should not highlight when in commit state");
            compare(get_indicator_item_at(4).highlighted, false, "Other indicators should not highlight when in commit state");
        }

        function test_commit_state() {
            init_test();

            indicatorRow.state = "commit";
            indicatorRow.setItem(0);

            compare(indicatorRow.currentItem.highlighted, true, "Indicator should highlight when in commit state");
            compare(get_indicator_item_at(1).highlighted, false, "Other indicators should not highlight when in commit state");
            compare(get_indicator_item_at(2).highlighted, false, "Other indicators should not highlight when in commit state");
            compare(get_indicator_item_at(3).highlighted, false, "Other indicators should not highlight when in commit state");
            compare(get_indicator_item_at(4).highlighted, false, "Other indicators should not highlight when in commit state");
        }

        function test_locked_state() {
            init_test();

            indicatorRow.state = "locked";
            indicatorRow.setItem(0);

            compare(indicatorRow.currentItem.highlighted, true, "Indicator should highlight when in locked state");
            compare(get_indicator_item_at(1).highlighted, false, "Other indicators should not highlight when in locked state");
            compare(get_indicator_item_at(2).highlighted, false, "Other indicators should not highlight when in locked state");
            compare(get_indicator_item_at(3).highlighted, false, "Other indicators should not highlight when in locked state");
            compare(get_indicator_item_at(4).highlighted, false, "Other indicators should not highlight when in locked state");
        }
    }

    UT.UnityTestCase {
        name: "IndicatorRow_Dimmed"
        when: windowShown

        function get_indicator_item_at(index) {
            return findChild(indicatorRow, "rowRepeater").itemAt(index);
        }

        function test_intial_state() {
            wait(1000)
            init_test();

            indicatorRow.state = "initial";
            indicatorRow.setItem(0);

            compare(get_indicator_item_at(0).dimmed, false, "Current indicator should not dim when in intiial state");
            compare(get_indicator_item_at(1).dimmed, false, "Other indicators should not dim when in initial state");
            compare(get_indicator_item_at(2).dimmed, false, "Other indicators should not dim when in initial state");
            compare(get_indicator_item_at(3).dimmed, false, "Other indicators should not dim when in initial state");
            compare(get_indicator_item_at(4).dimmed, false, "Other indicators should not dim when in initial state");
        }

        function test_hint_state() {
            init_test();

            indicatorRow.state = "hint";
            indicatorRow.setItem(0);

            compare(get_indicator_item_at(0).dimmed, true, "Current indicator should dim when in hint state");
            compare(get_indicator_item_at(1).dimmed, true, "Other indicators should dim when in hint state");
            compare(get_indicator_item_at(2).dimmed, true, "Other indicators should dim when in hint state");
            compare(get_indicator_item_at(3).dimmed, true, "Other indicators should dim when in hint state");
            compare(get_indicator_item_at(4).dimmed, true, "Other indicators should dim when in hint state");
        }

        function test_revealed_state() {
            init_test();

            indicatorRow.state = "reveal";
            indicatorRow.setItem(0);

            compare(get_indicator_item_at(0).dimmed, false, "Current indicator should not dim when in reveal state");
            compare(get_indicator_item_at(1).dimmed, true, "Other indicators should dim when in reveal state");
            compare(get_indicator_item_at(2).dimmed, true, "Other indicators should dim when in reveal state");
            compare(get_indicator_item_at(3).dimmed, true, "Other indicators should dim when in reveal state");
            compare(get_indicator_item_at(4).dimmed, true, "Other indicators should dim when in reveal state");
        }

        function test_commit_state() {
            init_test();

            indicatorRow.state = "commit";
            indicatorRow.setItem(0);

            compare(get_indicator_item_at(0).dimmed, false, "Current indicator should not dim when in commit state");
            compare(get_indicator_item_at(1).dimmed, true, "Other indicators should dim when in commit state");
            compare(get_indicator_item_at(2).dimmed, true, "Other indicators should dim when in commit state");
            compare(get_indicator_item_at(3).dimmed, true, "Other indicators should dim when in commit state");
            compare(get_indicator_item_at(4).dimmed, true, "Other indicators should dim when in commit state");
        }

        function test_locked_state() {
            init_test();

            indicatorRow.state = "locked";
            indicatorRow.setItem(0);

            compare(get_indicator_item_at(0).dimmed, false, "Current indicator should not dim when in locked state");
            compare(get_indicator_item_at(1).dimmed, true, "Other indicators should dim when in locked state");
            compare(get_indicator_item_at(2).dimmed, true, "Other indicators should dim when in locked state");
            compare(get_indicator_item_at(3).dimmed, true, "Other indicators should dim when in locked state");
            compare(get_indicator_item_at(4).dimmed, true, "Other indicators should dim when in locked state");
        }

        function test_active_overview() {
            init_test();

            indicatorRow.overviewActive = true;
            indicatorRow.state = "commit";

            compare(get_indicator_item_at(0).dimmed, true, "Indicator should dim when in overview");
            compare(get_indicator_item_at(1).dimmed, true, "Indicator should dim when in overview");
            compare(get_indicator_item_at(2).dimmed, true, "Indicator should dim when in overview");
            compare(get_indicator_item_at(3).dimmed, true, "Indicator should dim when in overview");
            compare(get_indicator_item_at(4).dimmed, true, "Indicator should dim when in overview");
        }
    }
}
