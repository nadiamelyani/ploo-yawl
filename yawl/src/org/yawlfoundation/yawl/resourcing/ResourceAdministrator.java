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

package org.yawlfoundation.yawl.resourcing;

import org.yawlfoundation.yawl.engine.interfce.WorkItemRecord;
import org.yawlfoundation.yawl.resourcing.resource.Participant;

import java.util.Set;

/**
 * Provides resource administration capabilties to authorised participants
 *
 *  @author Michael Adams
 *  v0.1, 03/09/2007
 */


public class ResourceAdministrator {

    private QueueSet _qSet  ;

    private static ResourceAdministrator _me ;

    private ResourceAdministrator() { }

    public static ResourceAdministrator getInstance() {
        if (_me == null) _me = new ResourceAdministrator() ;
        return _me;
    }

    public QueueSet getWorkQueues() {
        refreshWorklistedQueue();
        return _qSet ;
    }

    public void addToUnoffered(WorkItemRecord wir, boolean announce) {
        ResourceManager rm = ResourceManager.getInstance();
        rm.getWorkItemCache().updateResourceStatus(wir, WorkItemRecord.statusResourceUnoffered);
        _qSet.addToQueue(wir, WorkQueue.UNOFFERED);
        if (announce) rm.getClients().announceResourceUnavailable(wir);
    }

    public void addToUnoffered(WorkItemRecord wir) {
        addToUnoffered(wir, true);
    }


    public boolean removeFromAllQueues(WorkItemRecord wir) {
        _qSet.removeFromQueue(wir, WorkQueue.UNOFFERED);
        _qSet.removeFromQueue(wir, WorkQueue.WORKLISTED);
        return true;
    }

    public void removeCaseFromAllQueues(String caseID) {
        _qSet.removeCaseFromAllQueues(caseID);
    }

    public void createWorkQueues(boolean persisting) {
        _qSet = new QueueSet(null, QueueSet.setType.adminSet, persisting) ;
    }


    public boolean removeFromUnoffered(WorkItemRecord wir) {
        WorkQueue unoffered = _qSet.getQueue(WorkQueue.UNOFFERED);
        if (unoffered != null) unoffered.remove(wir);
        return unoffered != null;
    }


    public void attachWorkQueue(WorkQueue q, boolean persisting) {
        if (_qSet == null) createWorkQueues(persisting) ;
        _qSet.setQueue(q) ;
    }


    private void refreshWorklistedQueue() {
        if (_qSet == null) createWorkQueues(false) ;
        _qSet.purgeQueue(WorkQueue.WORKLISTED);

        Set<Participant> pSet = ResourceManager.getInstance().getOrgDataSet().getParticipants();
        for (Participant p : pSet)
            _qSet.addToQueue(WorkQueue.WORKLISTED, p.getWorkQueues().getWorklistedQueues());
    }

}
