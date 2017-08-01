/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * This file is available under the terms of the NASA Open Source Agreement
 * (NOSA). You should have received a copy of this agreement with the
 * Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 * 
 * No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 * WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 * INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 * WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 * INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 * FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 * TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 * CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 * OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 * OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 * FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 * REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 * AND DISTRIBUTES IT "AS IS."
 * 
 * Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 * AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 * SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 * THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 * EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 * PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 * SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 * STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 * PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 * REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 * TERMINATION OF THIS AGREEMENT.
 */

package gov.nasa.kepler.mc;

import gov.nasa.kepler.fs.api.FsId;

import java.util.Set;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hamcrest.Description;
import org.hamcrest.TypeSafeMatcher;

import com.google.common.collect.Sets;
import com.google.common.collect.Sets.SetView;
/**
 * For use with jmock.  This will generate a log message on a failed match.
 * <pre>
 *  Set<FsId> setOfFsId....
 *  final SetOfFsIdsMatcher mjdTimeSeriesIdsMatcher = 
 *      new SetOfFsIdsMatcher(setOfFsIds);
 *  mockery.checking(new Expectations() {{
 *      one(fsClient).readMjdTimeSeries(with(mjdTimeSeriesIdsMatcher), with(startMjd), with(endMjd));
 *      will(returnValue(...));
 *  }});
 *  </pre>
 * @author Sean McCauliff
*/
public class SetOfFsIdsMatcher extends TypeSafeMatcher<Set<FsId>> {

    private static final Log log = LogFactory.getLog(SetOfFsIdsMatcher.class);
    
    private final Set<FsId> expected;
    
    public SetOfFsIdsMatcher(Set<FsId> expected) {
        this.expected = expected;
    }
    
    @Override
    public void describeTo(Description arg0) {
        arg0.appendText("expected Set<FsId> " +
            ReflectionToStringBuilder.toString(expected));
    }

    @Override
    public boolean matchesSafely(Set<FsId> actualSet) {
        StringBuilder differences = new StringBuilder();
        
        SetView<FsId> onlyInExpected = Sets.difference(expected, actualSet);
        if (!onlyInExpected.isEmpty()) {
            differences.append("Expected set contains ids not present in the actual set.\n");
            for (FsId id : onlyInExpected) {
                differences.append(id).append("\n");
            }
        }
        
        SetView<FsId> onlyInActual = Sets.difference(actualSet, expected);
        if (!onlyInActual.isEmpty()) {
            differences.append("Actual set contains ids not found in the expected set.\n");
            for (FsId id : onlyInActual) {
                differences.append(id);
            }
        }
        
        if (differences.length() != 0) {
            log.error(differences);
            return false;
        }
        return true;
    }

}