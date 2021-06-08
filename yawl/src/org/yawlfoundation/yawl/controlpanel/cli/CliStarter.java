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

package org.yawlfoundation.yawl.controlpanel.cli;

import org.yawlfoundation.yawl.controlpanel.pubsub.EngineStatus;
import org.yawlfoundation.yawl.controlpanel.util.TomcatUtil;

import java.io.IOException;

/**
 * Starts tomcat from the command line
 *
 * @author Michael Adams
 * @date 19/11/2015
 */
public class CliStarter extends CliEngineController {

    public CliStarter() {
        super(EngineStatus.Stopped);
    }


    public void run() {
        try {
            if (TomcatUtil.start()) {
                System.out.print("Starting the YAWL Engine.");

                // user feedback while waiting for startup completion
                while (_engineStatus != EngineStatus.Running) {
                    pause(1000);
                }
                System.out.println("\nYAWL Engine started successfully.\n");
            }
            else {
                printError("Engine is already running.");
            }
        }
        catch (IOException ioe) {
            printError(ioe.getMessage());
        }

    }


    protected void printError(String msg) {
        super.printError("ERROR starting Engine: " + msg);
    }

}
