module.exports = web3 => {
    const getEvents = ({ logs = [] }, event) => logs.filter(l => l.event === event)
    const getEventAt = (receipt, event, index = 0) => getEvents(receipt, event)[index]
    const getEventArgument = (receipt, event, arg, index = 0) => getEventAt(receipt, event, index).args[arg]
    const getNewProxyAddress = (receipt) => getEventArgument(receipt, 'NewAppProxy', 'proxy')

    const assertEvent = (receipt, eventName, expectedArgs = {}, index = 0) => {
        const event = getEventAt(receipt, eventName, index)
        assert(typeof event === 'object', `could not find an emitted ${eventName} event ${index === 0 ? '' : `at index ${index}`}`)

        for (const arg of Object.keys(expectedArgs)) {
            let foundArg = event.args[arg]
            if (foundArg instanceof web3.BigNumber) foundArg = foundArg.toString()

            let expectedArg = expectedArgs[arg]
            if (expectedArg instanceof web3.BigNumber) expectedArg = expectedArg.toString()

            assert.equal(foundArg, expectedArg, `${eventName} event ${arg} value does not match`)
        }
    }

    const assertAmountOfEvents = (receipt, eventName, expectedAmount = 1) => {
        const events = getEvents(receipt, eventName)
        assert.equal(events.length, expectedAmount, `number of ${eventName} events does not match`)
    }

    return {
        getEvents,
        getEventAt,
        getEventArgument,
        getNewProxyAddress,
        assertEvent,
        assertAmountOfEvents
    }
}
