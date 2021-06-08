/*
 * Copyright (c) 2004-2020 The YAWL Foundation. All rights reserved.
 * The YAWL Foundation is a collaboration of individuals and
 * organisations who are committed to improving workflow technology.
 *
 * This file is part of YAWL. YAWL is free software: you can
 * redistribute it and/or modify it under the terms of the GNU Lesser
 * General Public License as published by the Free Software Foundation.
 *
 * YAWL is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General
 * Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with YAWL. If not, see <http://www.gnu.org/licenses/>.
 */

package org.yawlfoundation.yawl.stateless.engine.time;


import org.yawlfoundation.yawl.engine.WorkItemCompletion;
import org.yawlfoundation.yawl.engine.YWorkItemStatus;
import org.yawlfoundation.yawl.engine.time.YTimedObject;
import org.yawlfoundation.yawl.engine.time.YTimer;
import org.yawlfoundation.yawl.stateless.elements.YTask;
import org.yawlfoundation.yawl.stateless.engine.YEngine;
import org.yawlfoundation.yawl.stateless.engine.YWorkItem;

import javax.xml.datatype.Duration;
import java.util.Date;
import java.util.Set;

/**
 * A timer associated with an Atomic Task.
 *
 * Author: Michael Adams
 * Creation Date: 31/01/2008
 */

public class YWorkItemTimer implements YTimedObject {

    public enum Trigger { OnEnabled, OnExecuting, Never }

    public enum State { dormant, active, closed, expired }

    private YWorkItem _owner;     // the owner work item - each can have at most one timer
    private final long _endTime ;


    public YWorkItemTimer(YWorkItem item, long msec) {
        _owner = item ;
        _endTime = YTimer.getInstance().schedule(this, msec) ;
    }


    public YWorkItemTimer(YWorkItem item, Date expiryTime) {
        _owner = item ;
        _endTime = YTimer.getInstance().schedule(this, expiryTime) ;
    }


    public YWorkItemTimer(YWorkItem item, Duration duration) {
        _owner = item ;
        _endTime = YTimer.getInstance().schedule(this, duration) ;
    }


    public YWorkItemTimer(YWorkItem item, long units, YTimer.TimeUnit interval) {
        _owner = item ;
        _endTime = YTimer.getInstance().schedule(this, units, interval);
    }


    public String getOwnerID() { return _owner.getIDString(); }
    
    public long getEndTime() { return _endTime; }



    public boolean equals(Object other) {
        return (other instanceof YWorkItemTimer) &&
                ((getOwnerID() != null) ?
                 getOwnerID().equals(((YWorkItemTimer) other).getOwnerID()) :
                 super.equals(other));
    }

    public int hashCode() {
        return (getOwnerID() != null) ? getOwnerID().hashCode() : super.hashCode();
    }

            
    public void handleTimerExpiry() {
        if (_owner != null) {

            // special case: if the workitem timer started on enabled, and the item
            // has since been started, the ownerID now refers to the parent, and so the
            // child is needed so it can be expired correctly.
            if (_owner.getStatus().equals(YWorkItemStatus.statusIsParent)) {
                Set<YWorkItem> children = _owner.getChildren();
                if ((children != null) && (! children.isEmpty())) {
                    _owner = children.iterator().next();          // there will only be 1
                }
            }

            YTask task = _owner.getTask();
            task.getNetRunner().updateTimerState(task, State.expired);

            try {
                YEngine engine = new YEngine();
                if (_owner.getStatus().equals(YWorkItemStatus.statusEnabled)) {
                    if (_owner.requiresManualResourcing())              // not an autotask
                        engine.skipWorkItem(_owner) ;
                    task.getNetRunner().getAnnouncer().announceTimerExpiryEvent(_owner);
                }
                else if (_owner.hasUnfinishedStatus()) {
                    if (_owner.requiresManualResourcing())              // not an autotask
                        engine.completeWorkItem(_owner, _owner.getDataString(), null,
                                WorkItemCompletion.Force) ;
                    task.getNetRunner().getAnnouncer().announceTimerExpiryEvent(_owner);
                }
            }
            catch (Exception e) {
                // handle exc.
            }
        }
    }



    public void cancel() { }

}
